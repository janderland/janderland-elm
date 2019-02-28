#!/usr/bin/env node

const sqlite = require('sqlite')
const promise = require('bluebird')

sqlite.open('./database.sqlite', {promise})
  .then((db) => db.migrate({force: 'last'}))
  .catch((err) => {
    console.error(err)
    process.exitCode = 1
  })
