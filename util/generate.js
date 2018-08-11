let exec = require('child_process').execFile
let handlebars = require('handlebars')
let format = require('string-format')
let promise = require('bluebird')
let path = require('path')
let fs = require('fs')

let {
    zipObject,
    isEmpty,
    reduce,
    update,
    range,
    tail
} = require('lodash')

let writeFile = promise.promisify(fs.writeFile)
let readFile = promise.promisify(fs.readFile)
let readdir = promise.promisify(fs.readdir)



/*
 * Utilities
 */



// Feeds `stdin` to the process's stdin pipe,
// closes said pipe, and returns a promise
// for the stdout of the exited process.
// The `rejectedHandler' recieves an
// object with the following
// structure...
//
//     { exitCode: Int, stdout: String }
//
// ...where the exitCode and stdout values
// originate from `process`.

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



const missingCaptureMsg = `
Missing capture {}

in string...
{}

with regex...
{}
`

let missingCapture = (file, index, regex) =>
    throwErr(format(
        missingCaptureMsg,
        index,
        indentLines(file, spaces(4)),
        spaces(4) + regex
    ))


let fromCaptures = (file, names, regex) =>
    ((object, names) => {
        names.forEach((name, index) => {
            object[name] ||
                missingCapture(file, index, regex)
        })
        return object
    })(zipObject(names, captures(file, regex)), names)



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



let parseTags = (tags) =>
    isEmpty(tags)
        ? throwErr('Content tags must '+
            'have at least one item')
        : tags.replace(/\s+/g, ' ')
              .split('-')
              .map((s) => s.trim())
              .filter((s) => !isEmpty(s))



let captures = (string, regex) =>
    tail(string.match(regex))



/*
 * Generate Elm
 */



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



let formatElm = (generatedElm) =>
    promiseFromProcess(
        exec('elm-format', [ '--stdin' ]),
        generatedElm
    )



/*
 * Write Elm
 */



let writeElm = (elm) =>
    writeFile('Posts.elm', elm)



/*
 * Execution Root
 */



readFilesFromDir('content')

    .then(log('parsing content'))
    .map(parseFile)

    .then(log('generating elm'))
    .then(generateElm)

    .then(log('formatting elm'))
    .then(formatElm)

    .then(log('writing file'))
    .then(writeElm)

