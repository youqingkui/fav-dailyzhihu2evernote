request = require('request')
async = require('async')
txErr = require('./txErr')
cheerio = require('cheerio')
Evernote = require('evernote').Evernote
crypto = require('crypto')
makeNote = require('./createNote')
Task = require('../models/tasks')


class GetFav
  constructor:(token) ->
    @headers = {
      'Authorization':token
    }
    @url = 'http://news-at.zhihu.com/api/4/favorites'

  getList:() ->
    self = @
    op = {
      url:self.url
      headers:self.headers
    }
    async.waterfall [
      (cb) ->
        request.get op, (err, res, body) ->
          return txErr op.url, {err:err, fun:'getList'} if err

          data = JSON.parse(body)
          console.log "#####################################"
          console.log "find length ==> ", data.stories.length
          console.log "#####################################"
          cb(null, data)

      (data, cb) ->
        async.eachSeries data.stories, (item, callback) ->
          self.saveTask item.id, item.title, (err) ->
            return console.log err if err



            callback()

        ,() ->
          cb()


    ]






  saveTask:(id, title, cb) ->
    async.series [
      (callback) ->
        Task.findOne {id:id}, (err, row) ->
          return txErr "", 5, {err:err, fun:'saveTask-find'}, cb if err

          if not row
            callback()

          else
            console.log "#{id} => #{title} already exits"
            cb()



      (callback) ->
        newTask = new Task()
        newTask.id = id
        newTask.url = 'http://daily.zhihu.com/story/' + id
        newTask.title = title

        newTask.save (err, row) ->
          return txErr "", 5, {err:err, fun:'saveTask-save'},cb if err

          console.log "#{id} => #{title} add task db"
          cb()
    ]



module.exports = GetFav


