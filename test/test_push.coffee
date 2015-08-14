PushEvernote = require('../lib/pushEvernote')
Task = require('../models/tasks')
async = require('async')
txErr = require('../lib/txErr')
noteStore = require('../lib/noteStore')
schedule = require("node-schedule")
token = process.env.daily_zhihu
CheckAdd = require('../lib/checkAdd')


rule1 = new schedule.RecurrenceRule()
rule1.dayOfWeek = [0, new schedule.Range(1, 6)]
rule1.hour = 21
rule1.minute = 18


rule2 = new schedule.RecurrenceRule()
rule2.dayOfWeek = [0, new schedule.Range(1, 6)]
rule2.hour = 21
rule2.minute = 19


j1 = schedule.scheduleJob rule1, () ->
  ca = new CheckAdd(token)
  async.waterfall [
    (cb) ->
      ca.getList (err, data) ->
        return console.log err if err

        cb(null, data)

    (data, cb) ->
      ca.checkUP data, (err) ->
        return console.log err if err

        console.log "#check all do#"
  ]


j2 = schedule.scheduleJob rule2, () ->

  async.waterfall [
    (cb) ->
      Task.find {status:1}, null, {sort: {_id: -1}}, (err, rows) ->
        return txErr op.url, {err:err, fun:'getList-find'} if err

        for i in rows
          console.log i

        cb(null, rows)

    (tasks, cb) ->
      async.eachSeries tasks, (item, callback) ->
        p = new PushEvernote(noteStore, 'abfa14bd-8abf-4399-a0ee-70da3b253033', item.url, item.id, item.title)
        p.pushNote callback

      ,() ->
        console.log "all do"
        console.log "all do"
  ]


