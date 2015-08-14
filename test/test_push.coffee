PushEvernote = require('../lib/PushEvernote')
Task = require('../models/tasks')
async = require('async')
txErr = require('../lib/txErr')
noteStore = require('../lib/noteStore')


async.waterfall [
  (cb) ->
    Task.find {status:1}, null, {sort: {_id: -1}}, (err, rows) ->
      return txErr op.url, {err:err, fun:'getList-find'} if err

      for i in rows
        console.log i

      cb(null, rows)

  (tasks, cb) ->
    async.eachSeries tasks, (item, callback) ->
      p = new PushEvernote(noteStore, '', item.url, item.id, item.title)
      p.pushNote callback

    ,() ->
      console.log "all do"
      console.log "all do"
]


