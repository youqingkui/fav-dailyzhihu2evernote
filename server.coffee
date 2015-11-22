express = require('express')
async = require('async')
morgan = require('morgan')
compress = require('compression')

PushDaily = require('./lib/pushDaily')
ZhihuDaily = require('./models/zhihu_daily')
tx = require('./lib/txErr')
noteStore = require('./lib/noteStore')
CheckDaily = require('./lib/checkDaily')

app = express()
morgan.token 'date', () ->
  new Date().toString()
  
app.use(morgan('combined'))

# 是否检查
CHECK = true

app.get '/', (req, res) ->

  res.send('Hello World')


app.get '/do_task', (req, res) ->
  if CHECK
    res.send 'CHECK TRUE'
    CHECK = false

    async.waterfall [
      (cb) ->
        check = new CheckDaily()
        check.doTask(cb)

      (cb) ->
        ZhihuDaily.where({status:0}).orderBy('id DESC').find (err, rows) ->
          return txErr op.url, {err:err, fun:'getList-find'} if err


          cb(null, rows)

      (tasks, cb) ->
        async.eachSeries tasks, (item, callback) ->
          p = new PushDaily(noteStore, '735b3e76-e7f5-462c-84d0-bb1109bcd7dd', item.url, item.href, item.title)
          p.pushNote callback

        ,() ->
          CHECK = true
          console.info "all do"
      ]
  else
    res.send 'CHECK FALSE'










app.listen(3000)