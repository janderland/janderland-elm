#!/usr/bin/env node

let exec = require('child_process').execFile
let handlebars = require('handlebars')
let mkdirp = require('mkdirp-promise')
let format = require('string-format')
let promise = require('bluebird')
let crypto = require('crypto')
let moment = require('moment')
let Git = require('nodegit')
let path = require('path')
let os = require('os')
let fs = require('fs')

let {
    zipObject,
    isEmpty,
    update,
    reduce,
    sortBy,
    range,
    tail,
    set
} = require('lodash')

let writeFile = promise.promisify(fs.writeFile)
let readFile = promise.promisify(fs.readFile)
let readdir = promise.promisify(fs.readdir)



/*
 * Utilities
 */



// Returns a promise for the array of file content
// strings (UTF-8 is assumed) of every file that's
// an immediate child of `dir`.

/*
let readFilesFromDir = (dir) =>
    readdir(dir, { withFileTypes: true })
        .then((files) => promise.all(
            files.filter(file =>
                file.isFile()
            ).map((file) =>
                readFile(path.join(dir, file.name), 'utf8')
            )
        ))
*/



// Returns a promise for the array of file names
// of every file that's an immediate child of `dir`.

let readNamesFromDir = (dir) =>
    readdir(dir, { withFileTypes: true })
        .then((files) => promise.all(
            files.filter(file =>
                file.isFile()
            ).map((file) =>
              file.name
            )
        ))



let readingContent = (contentDir) => ({repo, versions}) =>
    promise.reduce(versions, (content, {name, versions}) =>
        promise.resolve(
            repo.checkoutBranch(refShorthand(name/*,  version */))
        )
    , [])



let loadVersions = ({names, repo}) =>
    promise.resolve(Git.Reference.list(repo))
        .map((id) => Git.Reference.lookup(repo, id))
        .filter((ref) => ref.isTag())
        .map(refCaptures)
        .filter((captures) => captures != null)
        .filter(([name, _]) => names.includes(name))
        .then(consolidateVersions(names))
        .filter(({_, versions}) => versions.length > 0)
        .then((versions) => ({repo, versions}))



let consolidateVersions = (names) => (versions) =>
    names.map((name) => ({
        name,
        versions: versions.filter(([name_, _]) =>
            name_ == name
        ).map(([_, version]) => version)
    }))



let contentNames = (filenames) =>
    filenames.map((name) =>
        name.match(/^(.+)\.md$/)[1]
    )



let randomName = () =>
    Math.random()
        .toString(36)
        .replace(/[^a-z]+/g, '')
        .substr(0, 5)



let refCaptures = (ref) =>
    captures(ref.shorthand(), /(.+)_V(.+)/)


let refShorthand = (name, version) =>
    name + '_V' + version



// This helper function allows me to throw
// from within a ternary operator.

let throwErr = (message) =>
    (() => { throw message })()



// This `fulfilledHandler` logs a message
// and then passes the promise's `value`
// on to the next `then()` call.

let log = (message) => (value) => {
    console.log(message)
    return value
}



// This `fulfilledHandler` logs the
// promise's `value` and then passes
// the value on to the next `then()`
// call.

let logValue = (value) => {
    console.log(value)
    return value
}



// Returns a string of `count` number
// of spaces.

let spaces = (count) =>
    reduce(range(count),
        (acc) => acc + ' ',
    '')



// Mutates `string` so that `tab` is
// prepended to each line.

let indentLines = (string, tab) =>
    reduce(string.split('\n'),
        (acc, s) => acc + tab + s + '\n',
    '')



/*
 * Content Parser
 */



// Parses a content file.

let parseFile = (file) => {
    let parsed = fromCaptures(
        file, ['meta', 'body'],
        /^(.*)---\n(.*)$/s
    )
    parsed.meta = parseMeta(parsed.meta)
    parsed.body = parseBody(parsed.body)
    return parsed
}



// Parses a content's meta section.

let parseMeta = (meta) => {
    let parsed = fromCaptures(
        meta, ['title', 'date', 'tags'],
        /^# ([^\n]+)\n\s*([^\n]+)\n\s*(-.+)$/s
    )
    parsed.date = parseDate(parsed.date)
    parsed.tags = parseTags(parsed.tags)
    parsed.id = parseId(parsed)
    return parsed
}



// Parses the date string into POSIX time.

let parseDate = (date) => {
    let m = moment(date)
    return m.isValid()
        ? m.valueOf()
        : throwErr('Failed to parse date '+date)
}



// Generates the content's ID by hashing the
// title and date.

let parseId = (parsed) => {
    let hash = crypto.createHash('sha256')
    hash.update(parsed.title + parsed.date)
    return hash.digest('hex').substring(0,8)
}



// Parses the tags portion of a content's
// meta section.

let parseTags = (tags) =>
    isEmpty(tags)
        ? throwErr('Content tags must '+
            'have at least one item')
        : tags.replace(/\s+/g, ' ')
              .split('-')
              .map((s) => s.trim())
              .filter((s) => !isEmpty(s))



// Escape the double quotes so we don't
// break strings in the output Elm.

let parseBody = (body) =>
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

let captureErr = (file, index, regex) =>
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

let fromCaptures = (string, names, regex) => {
    let object = zipObject(
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

let captures = (string, regex) =>
    tail(string.match(regex))



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



let generateElm = (parsedFiles) =>
    handlebars.compile(
      template,
      { noEscape: true }
    )({ contents: parsedFiles })



/*
 * Format Elm
 */



// Returns a promise for the elm source code
// after it's been passed through elm-format.

let formatElm = (generatedElm) =>
    promiseFromProcess(
        exec('elm-format', [ '--stdin' ]),
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

let promiseFromProcess = (process, stdin) => {
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



let writeElm = (file) => (elm) =>
    mkdirp(path.dirname(file)).then(() =>
        writeFile(file, elm)
    )



/*
 * Execution Root
 */



// Grab the required environment variables,
// ensuring they have been defined.

let env = reduce([
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



//readFilesFromDir(env.JANDER_CONTENT)
Promise.all([
  readNamesFromDir(env.JANDER_CONTENT),
  Git.Clone(".", path.join(os.tmpdir(), randomName()))
])

    .then(([filenames, repo]) => ({
        names: contentNames(filenames),
        repo
    }))

    .then(log('Loading versions'))
    .then(loadVersions)
    .then(logValue)

    .then(log('Reading content'))
    .then(readingContent(env.JANDER_CONTENT))
    .then(logValue)

/*
    .then(log('Parsing content'))
    .map(parseFile)

    .then((content) =>
        sortBy(
          content,
          (c) => -c.meta.date
        ))

    .then(log('Generating elm'))
    .then(generateElm)

    .then(log('Formatting elm'))
    .then(formatElm)

    .then(log('Writing file'))
    .then(writeElm(path.join(
        env.JANDER_BUILD,
        env.JANDER_GENERATED
    )))

*/
    .catch((err) => {
        console.error(err)
        process.exitCode = 1
    })
