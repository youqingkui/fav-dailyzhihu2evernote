noteStore = require('./noteStore')
async = require('async')
request = require('request')
Task = require('../models/tasks')
cheerio = require('cheerio')
inlineCss = require('inline-css')
crypto = require('crypto')
makeNote = require('./makeNote')
txErr = require('./txErr')
Evernote = require('evernote').Evernote





class PushEvernote
  constructor:(@noteStore, @noteBook, @url, @id, @title) ->
    @resourceArr = []


  pushNote:(cb) ->
    self = @
    async.series [
      (callback) ->
        self.changeContent (err) ->
          return cb() if err
          callback()

      (callback) ->
        self.createNote (err) ->
          return cb() if err

          callback()

      (callback) ->
        self.changeStatus (err) ->
          return cb() if err

          cb()

    ]


  # 创建笔记
  createNote:(cb) ->
    self = @
    makeNote self.noteStore, self.title.trim(), self.enContent,{sourceURL:self.url, resources:self.resourceArr, notebookGuid:self.noteBook},
      (err, note) ->
        return txErr {err:err, fun:'createNote', id:self.id}, cb(err) if err

        console.log "##############"
        console.log note.title + " create ok"
        console.log "##############"
        cb()

  # 标记完成
  changeStatus:(cb) ->
    self = @
    async.waterfall [
      (callback) ->
        Task.findOne {id:self.id}, (err, row) ->
          return txErr {err:err, fun:'changeStatus', id:self.id}, cb(err) if err

          if not row
            return txErr {err:'data not find', id:self.id}, cb("not find db")

          callback(null, row)

      (row, callback) ->
        row.status = 2
        row.save (err, res) ->
          return txErr {err:err, id:self.id}, cb(err) if err

          cb()
    ]

  # 获取并转换内容
  changeContent:(cb) ->
    self = @
    async.waterfall [
      (callback) ->
        request.get self.url, (err, res, body) ->
          return txErr {err:err, fun:'getContent', url:self.url}, cb(err) if err
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

        self.filterZhihu($)
        $cHtml = cheerio.load($contentDiv.html())
        self.filterHtml($cHtml)
        callback(null, $cHtml)

      ($cHtml, callback) ->
        self.changeImgHtml $cHtml, cb

    ]


  # 转换img标签
  changeImgHtml:($, cb) ->
    self = @
    imgs = $("img")
    console.log "#{self.title} find img length => #{imgs.length}"
    async.eachSeries imgs, (item, callback) ->
      src = $(item).attr('src')
      styleAttr = $(item).attr("style")
      styleAttr = "style=" + "'" + styleAttr + "'"

      self.readImgRes src, (err, resource) ->
        return txErr {err:err, title:self.title, url:src,fun:'changeContent-changeImgHtml'}, cb(err) if err

        self.resourceArr.push resource
        md5 = crypto.createHash('md5')
        md5.update(resource.image)
        hexHash = md5.digest('hex')
        newTag = "<en-media type=#{resource.mime} hash=#{hexHash} "  + styleAttr + " />"
#        newTag = "<en-media type=#{resource.mime} hash=#{hexHash} />"
        $(item).replaceWith(newTag)

        callback()

    ,() ->
      console.log "#{self.title} #{imgs.length} imgs down ok"
      self.enContent = $.html({xmlMode:true, decodeEntities: true})
#      console.log self.enContent
      cb()

  # 过滤掉知乎不需要HTML
  filterZhihu:($) ->
    global_header = $("body > div.global-header")[0]
    qr =  $("div.main-wrap.content-wrap > div.qr")[0]
    header_for_mobile = $("body > .header-for-mobile")[0]
    bottom_wrap = $("body > div.bottom-wrap")[0]
    $(global_header).remove()
    $(qr).remove()
    $(header_for_mobile).remove()
    $(bottom_wrap).remove()


  # 过滤HTML
  filterHtml:($) ->
    self = @

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


module.exports = PushEvernote
#p = new PushEvernote(noteStore, '', 'http://daily.zhihu.com/story/4726006', '4726006', 'hello')
#p.pushNote (err) ->
#  console.log err





