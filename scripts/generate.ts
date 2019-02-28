#!/usr/bin/env ts-node

import {execFile} from 'child_process'
import * as handlebars from 'handlebars'
import * as mkdirp from 'mkdirp-promise'
import * as format from 'string-format'
import * as promise from 'bluebird'
import * as crypto from 'crypto'
import * as moment from 'moment'
import * as path from 'path'
import * as fs from 'fs'

import {
  zipObject,
  isEmpty,
  reduce,
  sortBy,
  range,
  tail,
} from 'lodash'

const writeFile = promise.promisify(fs.writeFile)
const readFile = promise.promisify(fs.readFile)
const readdir = promise.promisify(fs.readdir)



/*
 * Utilities
 */



// Returns a promise for the array of file content
// strings (UTF-8 is assumed) of every file that's
// an immediate child of `dir`.

const readFilesFromDir = (dir) =>
  readdir(dir, {withFileTypes: true})
    .then((files) => promise.all(
      files.filter(file =>
        file.isFile()
      ).map((file) =>
        readFile(path.join(dir, file.name), 'utf8')
      )
    ))



// This helper function allows me to throw
// from within a ternary operator.

const throwErr = (message) =>
  (() => { throw message })()



// This `fulfilledHandler` logs a message
// and then passes the promise's `value`
// on to the next `then()` call.

const log = (message) => (value) => {
  console.log(message)
  return value
}



// This `fulfilledHandler` logs the
// promise's `value` and then passes
// the value on to the next `then()`
// call.

const logValue = (value) => {
  console.log(value)
  return value
}



// Returns a string of `count` number
// of spaces.

const spaces = (count) =>
  reduce(range(count),
    (acc) => acc + ' ',
  '')



// Mutates `string` so that `tab` is
// prepended to each line.

const indentLines = (string, tab) =>
  reduce(string.split('\n'),
    (acc, s) => acc + tab + s + '\n',
  '')



/*
 * Content Parser
 */



// Parses a content file.

const parseFile = (file) => {
  const parsed = fromCaptures(
    file, ['meta', 'body'],
    /^(.*)---\n(.*)$/s
  )
  parsed.meta = parseMeta(parsed.meta)
  parsed.body = parseBody(parsed.body)
  return parsed
}



// Parses a content's meta section.

const parseMeta = (meta) => {
  const parsed = fromCaptures(
    meta, ['title', 'date', 'tags'],
    /^# ([^\n]+)\n\s*([^\n]+)\n\s*(-.+)$/s
  )
  parsed.date = parseDate(parsed.date)
  parsed.tags = parseTags(parsed.tags)
  parsed.id = parseId(parsed)
  return parsed
}



// Parses the date string into POSIX time.

const parseDate = (date) => {
  const m = moment(date)
  return m.isValid()
    ? m.valueOf()
    : throwErr('Failed to parse date '+date)
}



// Generates the content's ID by hashing the
// title and date.

const parseId = (parsed) => {
  const hash = crypto.createHash('sha256')
  hash.update(parsed.title + parsed.date)
  return hash.digest('hex').substring(0,8)
}



// Parses the tags portion of a content's
// meta section.

const parseTags = (tags) =>
  isEmpty(tags)
    ? throwErr('Content tags must '+
      'have at least one item')
    : tags.replace(/\s+/g, ' ')
        .split('-')
        .map((s) => s.trim())
        .filter((s) => !isEmpty(s))



// Escape the double quotes so we don't
// break strings in the output Elm.

const parseBody = (body) =>
  body.replace(/\"/g, '\\"')



// The error message thrown by
// `captureErr()`.

const captureErrMsg = `
Missing capture {}

in string...
  {}

with regex...
  {}
`



// Throws an error outlining what capture
// is missing for what regex in what file.

const captureErr = (file, index, regex) =>
  throwErr(format(
    captureErrMsg,
    index,
    indentLines(file, spaces(4)).trim(),
    regex
  ))



// Creates an object with the captures obtained from applying
// `regex to `string`. The captures are added as values to the
// object using the `names` list as the keys. If there aren't
// enough captures for the names provided, an error is thrown.

const fromCaptures = (string, names, regex) => {
  const object = zipObject(
    names, captures(string, regex)
  )
  names.forEach((name, index) =>
    object[name]
      || captureErr(string, index, regex)
  )
  return object
}



// Returns a list of the captures obtained
// by apply `regex` to `string`.

const captures = (string, regex) =>
  tail(string.match(regex))



/*
 * Sort Content
 */



const sortContent = (content) =>
    sortBy(content, (c) => -c.meta.date)



/*
 * Generate Elm
 */



// The template used to generate the
// Content.elm file.

const template = `
module Contents exposing (Content, contentList, contentDict)

import Dict exposing (Dict)
import Time

type alias Content =
  { id : String
  , name : String
  , date : Time.Posix
  , tags : List String
  , body : String
  }

contentList : List Content
contentList =
  [ {{#each contents}}
    Content
      "{{this.meta.id}}"
      "{{this.meta.title}}"
      (Time.millisToPosix {{this.meta.date}})
      [ {{#each this.meta.tags}}
        "{{this}}"{{#unless @last}},{{/unless}}
      {{/each}} ]
      "{{this.body}}"
    {{#unless @last}},{{/unless}}
  {{/each}} ]

contentDict : Dict String Content
contentDict =
  contentList
    |> List.map (\\c -> (c.id, c))
    |> Dict.fromList
`



const generateElm = (parsedFiles) =>
  handlebars.compile(
    template,
    { noEscape: true }
  )({ contents: parsedFiles })



/*
 * Format Elm
 */



// Returns a promise for the elm source code
// after it's been passed through elm-format.

const formatElm = (generatedElm) =>
  promiseFromProcess(
    execFile('elm-format', [ '--stdin' ]),
    generatedElm
  )



// Feeds `stdin` to the process's stdin pipe,
// closes said pipe, and returns a promise
// for the stdout of the exited process. The
// promise is resolved if the process's exit
// code is 0. Otherwise, `rejectedHandler'
// recieves an object with the following
// structure...
//
//     { exitCode: Int, stdout: String }

const promiseFromProcess = (process, stdin) => {
  let stdout = ''
  return new Promise((resolve, reject) => {
    process.addListener('error', reject)
    process.addListener('exit', (exitCode) =>
      exitCode == 0
        ? resolve(stdout)
        : reject({
          exitCode: exitCode,
          stdout: stdout
        })
    )
    process.stdout.on('data', (data) =>
      stdout = stdout + data
    )
    process.stdin.write(stdin)
    process.stdin.end()
  })
}



/*
 * Write Elm
 */



const writeElm = (file) => (elm) =>
  mkdirp(path.dirname(file)).then(() =>
    writeFile(file, elm)
  )



/*
 * Execution Root
 */



// Grab the required environment variables,
// ensuring they have been defined.

const env = reduce([
    'JANDER_BUILD',
    'JANDER_CONTENT',
    'JANDER_GENERATED'
  ], (env, name) => {
      env[name] = process.env[name]
        || throwErr(
        'Missing environment ' +
        'variable "' + name + '"')
      return env
  }, {})



readFilesFromDir(env.JANDER_CONTENT)

  .then(log('Parsing content'))
  .map(parseFile)

  .then(log('Sorting content'))
  .then(sortContent)

  .then(log('Generating elm'))
  .then(generateElm)

  .then(log('Formatting elm'))
  .then(formatElm)

  .then(log('Writing file'))
  .then(writeElm(path.join(
    env.JANDER_BUILD,
    env.JANDER_GENERATED
  )))

  .catch((err) => {
    console.error(err)
    process.exitCode = 1
  })
