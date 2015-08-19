CheckAdd = require('../lib/checkAdd')
async = require('async')
token = process.env.daily_zhihu

ca = new CheckAdd(token)
async.waterfall [
  (cb) ->
    ca.getList (err, data) ->
      return console.log err if err

      cb(null, data)

  (data, cb) ->
    ca.checkUP data, (err) ->
      return console.log err if err

      console.log "all do"

]