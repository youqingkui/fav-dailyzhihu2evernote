mongoose = require('./mongoose')

DailySchema = mongoose.Schema
  href:{type:String, unique: true}
  url:{type:String, unique: true}
  guid:{type:String} # 笔记guid
  title:{type:String}
  status:{type:Number, default:0} # 0:默认，1:添加完成
  createTime:{type: Date, default:Date.now}


DailySchema.static.checkSame = (id, cb) ->
  DailySchema.findOne {id:id}, (err, row) ->
    return cb(err) if err

    if row
      cb(row)
    else
      cb()


module.exports = mongoose.model('Daily', DailySchema)