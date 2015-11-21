request = require('request')
async = require('async')
tx = require('./txErr')
cheerio = require('cheerio')
ZhihuDaily = require('../models/zhihu_daily')
noteStore = require('../lib/noteStore')

class CheckDaily
  constructor:() ->
    @url = "http://daily.zhihu.com/"
    @dailyArr = []


  doTask:(cb) ->
    _this = @
    async.waterfall [
      (callback) ->
        _this.getContent(callback)

      () ->
        _this.checkAdd(cb)

    ]


  getContent:(cb) ->
    _this = @
    op = _this.reqOp(_this.url)
    request.get op, (err, res, body) ->
      return tx {err:err, url:_this.url} if err

      $ = cheerio.load(body)
      $dailyRow = $(".main-content-wrap .link-button")
      if $dailyRow.length == 0
        return tx {err:"no $dailyRow length", url:_this.url, fun:'getContent', body:body}


      async.eachSeries $dailyRow, (row, callback) ->
        href = $(row).attr("href")
        title = $(row).find(".title").text()
        if not href or not title
          return tx {err:"not find title, href", fun:'checkAdd', row:row}, callback

        tmp = {}
        tmp.href = href
        tmp.title = title
        _this.dailyArr.push tmp
        callback()

      , () ->
        cb()


  checkAdd:(cb) ->
    _this = @
    async.eachSeries _this.dailyArr, (row, callback) ->
      _this.addRow(row.href, row.title, callback)

    ,() ->
      cb()



  addRow:(href, title, cb) ->
    async.series [
      (callback) ->
        ZhihuDaily.where({href:href}).findOne (err, row) ->
          if err
            tx {err:err, fun:'addRow', href:href, title:title}
            return cb()

          if row
            console.log "find same ==> #{href}, #{title}, #{row.title}"
            cb()
          else
            callback()

      (callback) ->
        daily = {}
        daily.href = href
        daily.title = title
        daily.url = "http://daily.zhihu.com#{href}"
        daily = ZhihuDaily.build daily
        daily.save (err, row) ->
          if err
            tx {err:err, fun:'addDaily', href:href, title:title}
            return cb()

          console.log("add ok #{row.title}, #{row.url}")
          cb()
    ]


  reqOp:(getUrl) ->
    options =
      url:getUrl
      headers:
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.90 Safari/537.36',

    return options


module.exports = CheckDaily



