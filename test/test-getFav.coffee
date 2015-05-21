GetFav = require('../lib/getFav')
noteStore = require('../lib/noteStore')
schedule = require("node-schedule")
rule = new schedule.RecurrenceRule()
rule.dayOfWeek = [0, new schedule.Range(1, 6)]
rule.hour = 9
rule.minute = 30

j = schedule.scheduleJob rule, () ->
  token = process.env.daily_zhihu
  g = new GetFav(token)
  g.getList()