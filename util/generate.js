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
        'tags',
        parseTags
    )



const fileKeys = ['meta', 'body']

let parseFile = (file) =>
    update(
        zipObject(
            fileKeys,
            captures(file, /^(.*)---\n(.*)$/s)
        ),
        fileKeys[0],
        parseMeta
    )



let readFilesFromDir = (dir) =>
    readdir(dir).then((fileNames) =>
        promise.all(fileNames.map((fileName) =>
            readFile(path.join(dir, fileName), 'utf8')
        ))
    )



readFilesFromDir('content').then((files) =>
    console.log(files.map(parseFile))
)

