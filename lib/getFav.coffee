request = require('request')
async = require('async')
txErr = require('./txErr')
cheerio = require('cheerio')
Evernote = require('evernote').Evernote
crypto = require('crypto')
makeNote = require('./createNote')


class GetFav
  constructor:(token) ->
    @headers = {
      'Authorization':"Bearer #{token}"
    }
    @url = 'http://news-at.zhihu.com/api/4/favorites'

  getList:() ->
    self = @
    op = {
      url:self.url
      headers:self.headers
    }


