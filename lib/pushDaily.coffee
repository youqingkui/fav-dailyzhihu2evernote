PushEvernote = require('./pushEvernote')
Daily = require('../models/daily')
ZhihuDaily = require('../models/zhihu_daily')
async = require('async')
tx = require('./txErr')
noteStore = require('./noteStore')



class PushDaily extends PushEvernote
  constructor:(@noteStore, @noteBook, @url, @id, @title) ->
    super

  # 标记完成
  changeStatus:(cb) ->
    self = @
    async.waterfall [
      (callback) ->
        ZhihuDaily.where({href:self.id}).findOne (err, row) ->
          return tx {err:err, fun:'changeStatus', id:self.id}, cb(err) if err

          if not row
            return tx {err:'data not find', id:self.id}, cb("not find db")

          callback(null, row)

      (row, callback) ->
        row.status = 2
        row.guid = self.guid
        row.save (err, res) ->
          return tx {err:err, id:self.id}, cb(err) if err

          cb()
    ]


module.exports = PushDaily


#async.waterfall [
#  (cb) ->
#    Daily.find {status:0}, null, {sort: {_id: -1}}, (err, rows) ->
#      return txErr op.url, {err:err, fun:'getList-find'} if err
#
#      for i in rows
#        console.log i
#
#      cb(null, rows)
#
#  (tasks, cb) ->
#    async.eachSeries tasks, (item, callback) ->
#      p = new PushDaily(noteStore, 'af0137f4-89c6-4ad1-9bde-758bdcf378c1', item.url, item.href, item.title)
#      p.pushNote callback
#
#    ,() ->
#      console.log "all do"
#]


