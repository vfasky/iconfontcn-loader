###*
 *
 * 阿里字体下载
 * @author vfasky <vfasky@gmail.com>
###
'use strict'

loaderUtils = require 'loader-utils'
request = require 'request'
path = require 'path'
fs = require 'fs-plus'

alicdnReg = /\@import\s+url\([^\)]*at\.alicdn\.com\/t\/font[^\;]+\);?/ig
urlReg = /\/\/[^\(]*at\.alicdn\.com\/t\/font[^\.css]+/i

fontUrlReg = /\/\/[^\(]*at\.alicdn\.com\/t\/font[^']+/ig

parseCss = (css, loader, done = ->)->
    query = loaderUtils.parseQuery loader.query
    loaderContext = loader.context or= query.context
    sourcePathInfo = path.parse loader.resourcePath

    fontDir = path.join sourcePathInfo.dir, 'font'
    fs.makeTreeSync fontDir if false == fs.isDirectorySync fontDir

    downFiles = []
    total = 0
    css.replace fontUrlReg, (fontUrl)->
        url = fontUrl.split('?').shift().split('#').shift()
        if url not in downFiles
            downFiles.push url
        fontUrl

    doneDownFiles = ->
        done css

    for fontUrl in downFiles
        pathInfo = path.parse fontUrl
        baseUrl = './font/' + pathInfo.base
        fullUrl = path.join sourcePathInfo.dir, baseUrl

        do (fontUrl, baseUrl)->
            request.get 'http:' + fontUrl
                   .on 'response', ->
                       total++
                       reg = new RegExp fontUrl, 'ig'
                       css = css.replace reg, baseUrl
                       doneDownFiles() if total == downFiles.length

                   .pipe fs.createWriteStream fullUrl


module.exports = (css)->

    this.cacheable() if this.cacheable
    callback = this.async()

    loader = @

    _reId = 0
    reMap = {}
    total = 0
    done = 0

    css = css.replace alicdnReg, (importUrl)->
        res = importUrl.match urlReg
        cssUrl = 'http:' + res[0] + '.css'

        # 如果url已经存在，删除这条import
        return '' if reMap[cssUrl]

        _reId++
        reName = "/*{__replace__alicdn__#{_reId}}*/"
        total++

        reMap[cssUrl] =
            name: reName
            soure: importUrl

        reName


    for cssUrl of reMap
        do (cssUrl)-> request cssUrl, (err, res, body)->
            return callback err if err

            parseCss body, loader, (fontCss)->
                done++
                css = css.replace reMap[cssUrl].name, fontCss
                if done == total
                    callback null, css