iconfontcn-loader
=================

iconfont-loader for iconfont.cn

解释 css 中的 `@import url("//at.alicdn.com/t/font_1456128288_5614772.css");` 从 iconfont.cn 替换相对的 css 及下载字体到本地

### install

```
npm install iconfontcn-loader --save-dev
```

### demo

```js
//webpack.config.js
module: {
    loaders: [{
        test: /\.scss$/,
        loader: ExtractTextPlugin.extract('style-loader', 'css?sourceMap!autoprefixer!iconfontcn!sass?sourceMap')
    }, {
        test: /\.(jpe?g|png|gif|svg)$/i,
        loader: 'url-loader?limit=10000&name=img/[hash:8].[name].[ext]'
    }, {
        test: /\.woff(2)?(\?v=[0-9]\.[0-9]\.[0-9])?$/,
        loader: "url-loader?limit=10000&name=font/[hash:8].[name].[ext]&mimetype=application/font-woff"
    }, {
        test: /\.(ttf|eot|svg)(\?v=[0-9]\.[0-9]\.[0-9])?$/,
        loader: "url-loader?limit=10000&name=font/[hash:8].[name].[ext]"
    }]
},
```
