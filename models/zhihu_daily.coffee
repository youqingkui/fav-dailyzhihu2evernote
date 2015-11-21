T = require("toshihiko")
# 数据库连接配置
toshihiko = require("./toshihiko.js")

ZhihuDaily = toshihiko.define 'zhihu_daily',
  [
    {
      name: "id"
      type: T.Type.Integer
      primaryKey: true
    }
    {
      name: "href"
      type: T.Type.String
      defaultValue: ""
    }
    {
      name: "url"
      type: T.Type.String
      defaultValue: ""
    }
    {
      name: "guid"
      type: T.Type.String
      defaultValue: ""
    }
    {
      name: "title"
      type: T.Type.String
      defaultValue: ""
    }
    {
      name: "status"
      type: T.Type.Integer
      defaultValue: "0"
    }
    {
      name: "create_time"
      type: T.Type.Integer
      defaultValue: "0"
    }
  ]

module.exports = ZhihuDaily
#
#ZhihuDaily.find (err, row) ->
#  return console.log err if err
#
#  for i in row
#    console.log i.id
