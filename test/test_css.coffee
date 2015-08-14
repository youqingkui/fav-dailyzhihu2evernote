request = require('request')
inlineCss = require('inline-css')
cheerio = require('cheerio')
async = require('async')
SaveEvernote = require('../lib/getArticle')
noteStore = require('../lib/noteStore')

url = 'http://daily.zhihu.com/story/4726006'

async.waterfall [
  (cb) ->
    request.get url, (err, res, body) ->
      return console.log err if err


      cb(null, body)

  (body, cb) ->
    inlineCss body, {url:'http://daily.zhihu.com'}, (err, html) ->
      return console.log "err",   err if err

      cb(null, html)

  (html, cb) ->
    $ = cheerio.load(html)
    $contentDiv = $("body")
    if $contentDiv.length is 0
      return console.log "not find content div"

    $(".global-header").remove()
    $("script").remove()
    $("*").map (i, elem) ->
      for k, v of elem.attribs
        if k != 'style' && k !="src" && k != "href"
          $(this).removeAttr(k)


    $ = cheerio.load($contentDiv.html())
    changHtml = $.html()
    console.log "changHtml ####################"
    console.log changHtml
    console.log "changHtml ####################"
    cb(null, changHtml)

  (changeHtml, cb) ->
    se = new SaveEvernote(123, noteStore)
    se.content = changeHtml
    se.title = "测试"
    async.series [
      (callback) ->
        se.changeContent (err) ->
          return console.log err if err

          callback()

      (callback) ->
        console.log "createNote"
        console.log se.enContent
        se.createNote (err) ->
          return console.log err if err
    ]


]