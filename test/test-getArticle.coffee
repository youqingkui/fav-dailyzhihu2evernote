noteStore = require('../lib/noteStore')
SaveEvernote = require('../lib/getArticle')
async = require('async')

id = '4739830'
noteBook = 'abfa14bd-8abf-4399-a0ee-70da3b253033'

s = new SaveEvernote(id, noteStore, noteBook)

async.series [
  (callback) ->
    s.getInfo (err) ->
      return console.log err if err

      callback()

  (callback) ->
    s.changeContent (err) ->
      return console.log err if err

      callback()

  (callback) ->
    s.createNote (err) ->
      return console.log err if err

      callback()

]
