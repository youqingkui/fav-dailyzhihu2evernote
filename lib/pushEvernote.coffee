noteStore = require('./noteStore')
async = require('async')
request = require('request')
Task = require('../models/tasks')
cheerio = require('cheerio')
inlineCss = require('inline-css')
crypto = require('crypto')
makeNote = require('./makeNote')




class PushEvernote
  constructor:(@noteStore, @noteBook) ->


  pushNote:(html, cb) ->




  findTask: (cb) ->
    Task.find {status:1}, null, {sort: {_id: -1}}, (err, rows) ->
      return txErr {err:err, fun:'findTask-find'}, cb(err) if err

      cb(null, rows)


  changeContent:(url, title, cb) ->
    self = @
    async.waterfall [
      (callback) ->
        request.get url, (err, res, body) ->
          return txErr {err:err, fun:'getContent', url:url}, cb(err) if err

          callback(null, body)

      (body, callback) ->
        inlineCss body, {url:'http://daily.zhihu.com'}, (err, html) ->
          return txErr {body:body, err:err, fun:'changeContent-inlineCss'}, cb(err) if err

          callback(null, html)

      (html, callback) ->
        $ = cheerio.load(html)
        $contentDiv = $("body")
        if $contentDiv.length is 0
          return txErr {
            err:'not content', fun:'changeContent-cherrio', html:html
          }, cb('not content')

        $cHtml = cheerio.load($contentDiv.html())
        self.filterHtml($cHtml)
        callback(null, $cHtml)

      ($cHtml, callback) ->
        self.changeImgHtml $cHtml, title, cb

    ]


  # 转换img标签
  changeImgHtml:($,title, cb) ->
    self = @
    imgs = $("img")
    console.log "#{title} find img length => #{imgs.length}"
    async.eachSeries imgs, (item, callback) ->
      src = $(item).attr('src')
      styleAttr = $(item).attr("style")
      styleAttr = "style=" + "'" + styleAttr + "'"

      self.readImgRes src, (err, resource) ->
        return txErr {err:err, title:title, url:src,fun:'changeContent-changeImgHtml'}, cb(err) if err

        self.resourceArr.push resource
        md5 = crypto.createHash('md5')
        md5.update(resource.image)
        hexHash = md5.digest('hex')
        newTag = "<en-media type=#{resource.mime} hash=#{hexHash} "  + styleAttr + " />"
        $(item).replaceWith(newTag)

        callback()

    ,() ->
      console.log "#{title} #{imgs.length} imgs down ok"
      self.enContent = $.html({xmlMode:true, decodeEntities: false})
      cb()


  # 过滤HTML
  filterHtml:($) ->
    self = @
    $(".global-header").remove()

    $("script").remove()

    $("*").map (i, elem) ->
      for k, v of elem.attribs
        if k != 'style' && k !="src" && k != "href"
          $(this).removeAttr(k)

        if k is 'href'
          if !self.checkUrl(v)
            $(this).removeAttr(k)

    $("iframe").remove()

    $("article").each () ->
      $(this).replaceWith('<div>'+ $(this).html()+ '</div>')

    $("section").each () ->
      $(this).replaceWith('<div>'+ $(this).html()+ '</div>')

    $("header").each () ->
      $(this).replaceWith('<div>'+ $(this).html()+ '</div>')

    $("noscript").each () ->
      $(this).replaceWith('<div>'+ $(this).html()+ '</div>')


    $("figure").each () ->
      $(this).replaceWith('<div>'+ $(this).html()+ '</div>')

    $("figcaption").each () ->
      $(this).replaceWith('<div>'+ $(this).html()+ '</div>')

  # 检查URL是否合法
  checkUrl:(href) ->
    strRegex = "^((https|http|ftp|rtsp|mms)?://)"
    + "?(([0-9a-z_!~*'().&=+$%-]+: )?[0-9a-z_!~*'().&=+$%-]+@)?"
    + "(([0-9]{1,3}/.){3}[0-9]{1,3}" + "|"
    + "([0-9a-z_!~*'()-]+/.)*"
    + "([0-9a-z][0-9a-z-]{0,61})?[0-9a-z]/."
    + "[a-z]{2,6})"
    + "(:[0-9]{1,4})?"
    + "((/?)|"
    + "(/[0-9a-z_!~*'().;?:@&=+$,%#-]+)+/?)$"

    re = new RegExp(strRegex)
    if re.test href
      return true

    else
      return false


  # 读取编码远程图片
  readImgRes: (imgUrl, cb) ->
    self = @
    op = self.reqOp(imgUrl)
    op.encoding = 'binary'
    async.auto
      readImg:(callback) ->
        request.get op, (err, res, body) ->
          return cb(err) if err
          mimeType = res.headers['content-type']
          mimeType = mimeType.split(';')[0]
          callback(null, body, mimeType)

      enImg:['readImg', (callback, result) ->
        mimeType = result.readImg[1]
        image = new Buffer(result.readImg[0], 'binary')
        hash = image.toString('base64')

        data = new Evernote.Data()
        data.size = image.length
        data.bodyHash = hash
        data.body = image

        resource = new Evernote.Resource()
        resource.mime = mimeType
        resource.data = data
        resource.image = image
        cb(null, resource)
      ]


  reqOp:(getUrl) ->
    options =
      url:getUrl
      headers:
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.90 Safari/537.36',

    return options

p = new PushEvernote()
p.changeContent('http://daily.zhihu.com/story/4744440', 'hello')





