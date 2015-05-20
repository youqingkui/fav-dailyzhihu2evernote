GetFav = require('../lib/getFav')
noteStore = require('../lib/noteStore')


token = process.env.daily_zhihu

g = new GetFav(token)
g.getList()