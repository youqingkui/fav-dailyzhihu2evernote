express = require('express')
async = require('async')
morgan = require('morgan')
compress = require('compression')

PushDaily = require('./lib/pushDaily')
ZhihuDaily = require('./models/zhihu_daily')
txErr = require('./lib/txErr')
noteStore = require('./lib/noteStore')
CheckDaily = require('./lib/checkDaily')
cargo = require('./lib/cargo')

app = express()
morgan.token 'date', () ->
  new Date().toString()

app.use(morgan('combined'))



app.get '/', (req, res) ->

  res.send('Hello World')


app.get '/do_task', (req, res) ->

  async.waterfall [

    (cb) ->
      check = new CheckDaily()
      check.doTask(cb)

    (cb) ->
      ZhihuDaily.where({status:0}).orderBy('id DESC').find (err, rows) ->
        return txErr op.url, {err:err, fun:'getList-find'} if err


        cb(null, rows)

    (tasks, cb) ->
      tasks.forEach (item) ->
        p = new PushDaily(noteStore, '735b3e76-e7f5-462c-84d0-bb1109bcd7dd', item.url, item.href, item.title)
        cargo.push {name:item.title, run:(callback) -> p.pushNote callback }
      ,() ->
        console.log "all do"
  ]

  res.send "ok"









app.listen(3000)