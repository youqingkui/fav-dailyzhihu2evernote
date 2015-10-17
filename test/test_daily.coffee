PushDaily = require('../lib/pushDaily')
Daily = require('../models/daily')
async = require('async')
tx = require('../lib/txErr')
noteStore = require('../lib/noteStore')
schedule = require("node-schedule")
CheckDaily = require('../lib/checkDaily')


rule = new schedule.RecurrenceRule()
rule.minute = 30


j = schedule.scheduleJob rule, () ->
  async.waterfall [

    (cb) ->
      check = new CheckDaily()
      check.doTask(cb)

    (cb) ->
      Daily.find {status:0}, null, {sort: {_id: -1}}, (err, rows) ->
        return txErr op.url, {err:err, fun:'getList-find'} if err


        cb(null, rows)

    (tasks, cb) ->
      async.eachSeries tasks, (item, callback) ->
        p = new PushDaily(noteStore, 'af0137f4-89c6-4ad1-9bde-758bdcf378c1', item.url, item.href, item.title)
        p.pushNote callback

      ,() ->
        console.log "all do"
  ]
