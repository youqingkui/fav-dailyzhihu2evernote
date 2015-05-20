GetFav = require('../lib/getFav')

token = process.env.daily_zhihu

g = new GetFav(token)
g.getList()