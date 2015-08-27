request = require('request')
async = require('async')
txErr = require('./txErr')
Task = require('../models/tasks')
noteStore = require('../lib/noteStore')


class CheckAdd
  constructor: (token) ->
    @headers = {
      'Authorization':token
    }
    @url = 'http://news-at.zhihu.com/api/4/favorites'


  getList:(cb) ->
    self = @
    op = {
      url:self.url
      headers:self.headers
    }
    request.get op, (err, res, body) ->
      return txErr {url:op.url, fun:'getList', err:err}, cb if err

      data = JSON.parse(body)
      console.log "#####################################"
      console.log "find length ==> ", data.stories.length
      console.log "#####################################"

      cb(null, data)

  checkUP:(data, cb) ->
    self = @
    async.eachSeries data.stories, (item, callback) ->
      Task.findOne {id:item.id}, (err, row) ->
        return txErr {fun:'checkUP-find', err:err}, cb if err

        if row
          console.log "find same", row.title, row.id
          callback()

        else
          self.addTask item, (err, task) ->
            return console.log err if err

            callback()

    ,(sErr) ->
      return cb(sErr) if sErr

      cb()


  addTask:(taskInfo, cb) ->
    task = Task()
    task.id = taskInfo.id
    task.title = taskInfo.title.trim()
    task.url = 'http://daily.zhihu.com/story/' + task.id

    task.save (err, row) ->
      return txErr {fun:'addTask', err:err}, cb if err
      console.log "已添加：", taskInfo.title, taskInfo.id
      console.log "\n"
      cb(null, row)


module.exports = CheckAdd





