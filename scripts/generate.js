#!/usr/bin/env node

let exec = require('child_process').execFile
let handlebars = require('handlebars')
let mkdirp = require('mkdirp-promise')
let format = require('string-format')
let promise = require('bluebird')
let path = require('path')
let fs = require('fs')

let {
    zipObject,
    isEmpty,
    reduce,
    update,
    every,
    range,
    tail
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

let readFilesFromDir = (dir) =>
    readdir(dir).then((fileNames) =>
        promise.all(fileNames.map((fileName) =>
            readFile(path.join(dir, fileName), 'utf8')
        ))
    )



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

let parseFile = (file) =>
    update(
        fromCaptures(
            file,
            ['meta', 'body'],
            /^(.*)---\n(.*)$/s
        ),
        'meta',
        parseMeta
    )



// Parses a content's meta section.

let parseMeta = (meta) =>
    update(
        fromCaptures(
            meta,
            ['title', 'date', 'tags'],
            /^# ([^\n]+)\n\s*([^\n]+)\n\s*(-.+)$/s
        ),
        'tags',
        parseTags
    )



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
// Posts.elm file.

const template = `
module Posts exposing (posts)

import Dict exposing (Dict)
import Date exposing (Date)

type alias Posts =
    Dict Int Content

type alias Content =
    { id : Int
    , name : String
    , date : Date
    , tags : List String
    , body : String
    }

entry : Content -> ( Int, Content )
entry content =
    ( content.id, content)

posts : Posts
posts = [
    {{#each posts}}
    Content
        {{@index}}
        "{{this.meta.title}}"
        (Date.fromTime 0)
        [
            {{#each this.meta.tags}}
                "{{this}}"{{#unless @last}},{{/unless}}
            {{/each}}
        ]
        "{{this.body}}"
        {{#unless @last}},{{/unless}}
    {{/each}}
    ]
        |> List.map entry
        |> Dict.fromList
`



let generateElm = (parsedFiles) =>
    handlebars.compile(template)({ posts: parsedFiles })



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



let getEnvVar = (name) =>
    process.env[name] || throwErr(
        'Missing environment variable "' + name + '"'
    )



let build = getEnvVar('JANDER_BUILD')
let posts = getEnvVar('JANDER_POSTS')
let content = getEnvVar('JANDER_CONTENT')
let outfile = path.join(build, posts)



readFilesFromDir(content)

    .then(log('parsing content'))
    .map(parseFile)

    .then(log('generating elm'))
    .then(generateElm)

    .then(log('formatting elm'))
    .then(formatElm)

    .then(log('writing file'))
    .then(writeElm(outfile))

    .catch((err) => {
        console.error(err)
        process.exitCode = 1
    })

