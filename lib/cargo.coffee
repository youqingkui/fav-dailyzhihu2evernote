async = require('async')
log = console.log

###*
# 创建cargo实例
###

cargo = async.cargo(((tasks, cb) ->
  async.each tasks, (item, callback) ->
    console.log "start #{item.name}"
    item.run (err) ->
      callback()

  ,() ->
    cb()

), 2)

###*
# 监听：如果某次push操作后，任务数将达到或超过worker数量时，将调用该函数
###

cargo.saturated = ->
  log 'all workers to be used'
  return

###*
# 监听：当最后一个任务交给worker时，将调用该函数
###

cargo.empty = ->
  log 'no more tasks wating'
  return

###*
# 监听：当所有任务都执行完以后，将调用该函数
###

cargo.drain = ->
  log 'all tasks have been processed'
  return


module.exports = cargo