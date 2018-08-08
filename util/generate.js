let handlebars = require('handlebars')
let pretty = require('pretty-print')
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



let captures = (string, regex) =>
    tail(string.match(regex))



let parseTags = (tags) =>
    tags.replace(/\s+/g, ' ')
        .split('-')
        .map((s) => s.trim())
        .filter((s) => !isEmpty(s))



const metaKeys = ['title', 'date', 'tags']

let metaRegExp =
    new RegExp('^' +
        metaKeys.reduce((expr, key) =>
            expr + key + ':(.*)\n', ''
        ) + '$',
        's'
    )

let parseMeta = (meta) =>
    update(
        zipObject(
            metaKeys,
            captures(meta, metaRegExp)
        ),
        'tags', parseTags
    )



const fileKeys = ['meta', 'body']

let parseFile = (file) =>
    update(
        zipObject(
            fileKeys,
            captures(file, /^(.*)---\n(.*)$/s)
        ),
        'meta', parseMeta
    )



let readFilesFromDir = (dir) =>
    readdir(dir).then((fileNames) =>
        promise.all(fileNames.map((fileName) =>
            readFile(path.join(dir, fileName), 'utf8')
        ))
    )



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

let generate = (parsedFiles) =>
    handlebars.compile(template)({ posts: parsedFiles })



readFilesFromDir('content').then((files) => {
    let parsedFiles = files.map(parseFile)
    console.log(parsedFiles)
    writeFile(
        'Posts.elm',
        generate(parsedFiles)
    )
})

