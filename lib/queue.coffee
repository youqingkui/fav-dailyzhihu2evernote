async = require('async')
SaveEvernote = require('./getArticle')

q = async.queue (data, cb) ->
  console.log "#{data.id} => #{data.title} [now do]"
  g = new SaveEvernote(data.id, data.noteStore, data.noteBook)
  async.series [

    (callback) ->
      g.getInfo(callback)

    (callback) ->
      g.changeContent(callback)

    (callback) ->
      g.createNote(callback)


  ],(err) ->
    return cb(err) if err
    cb()
, 1



q.saturated = () ->
  console.log('all workers to be used')


q.empty = () ->
  console.log('no more tasks wating')


q.drain = () ->
  console.log('all tasks have been processed')

module.exports = q