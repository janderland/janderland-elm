let exec = require('child_process').execFile
let handlebars = require('handlebars')
let promise = require('bluebird')
let path = require('path')
let fs = require('fs')

let {
    zipObject,
    isEmpty,
    update,
    tail
} = require('lodash')

let writeFile = promise.promisify(fs.writeFile)
let readFile = promise.promisify(fs.readFile)
let readdir = promise.promisify(fs.readdir)



// Utilities



let promiseFromProcess = (process, stdin) => {
    let stdout
    return new Promise((resolve, reject) => {
        process.addListener('error', reject)
        process.addListener('exit', (exitCode) =>
            resolve({
                exitCode: exitCode,
                stdout: stdout
            })
        )
        process.stdout.on('data', (data) =>
            stdout = data
        )
        process.stdin.write(stdin)
        process.stdin.end()
    })
}



let readFilesFromDir = (dir) =>
    readdir(dir).then((fileNames) =>
        promise.all(fileNames.map((fileName) =>
            readFile(path.join(dir, fileName), 'utf8')
        ))
    )


let log = (message) => (value) => {
        console.log(message)
        return value
    }



// Content Parser



const fileKeys = ['meta', 'body']

let parseFile = (file) =>
    update(
        zipObject(
            fileKeys,
            captures(file, /^(.*)---\n(.*)$/s)
        ),
        'meta',
        parseMeta
    )



const metaKeys = ['title', 'date', 'tags']

let parseMeta = (meta) =>
    update(
        zipObject(
            metaKeys,
            captures(meta, metaRegExp)
        ),
        'tags',
        parseTags
    )

let metaRegExp =
    new RegExp('^' +
        metaKeys.reduce((expr, key) =>
            expr + key + ':(.*)\n', ''
        ) + '$',
        's'
    )



let parseTags = (tags) =>
    tags.replace(/\s+/g, ' ')
        .split('-')
        .map((s) => s.trim())
        .filter((s) => !isEmpty(s))



let captures = (string, regex) =>
    tail(string.match(regex))



// Elm Generator



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
        '{{this.meta.title}}'
        (Date.fromTime 0)
        [
            {{#each this.meta.tags}}
                '{{this}}'{{#unless @last}},{{/unless}}
            {{/each}}
        ]
        '{{this.body}}'
        {{#unless @last}},{{/unless}}
    {{/each}}
    ]
        |> List.map entry
        |> Dict.fromList
`

let generate = (parsedFiles) =>
    handlebars.compile(template)({ posts: parsedFiles })



// Elm Formatting



let format = (generatedElm) =>
    promiseFromProcess(
        exec('elm-format', [ '--stdin' ]),
        generatedElm
    )



// Write File



let write = (result) =>
    writeFile('Posts.elm', result.stdout)



// Execution Root



readFilesFromDir('content')

    .then(log('parsing content'))
    .map(parseFile)

    .then(log('generating elm'))
    .then(generate)

    .then(log('formatting elm'))
    .then(format)

    .then(log('writing file'))
    .then(write)

