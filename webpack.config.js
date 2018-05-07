'use strict';

const path = require('path');
const webpack = require('webpack');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');

const devMode = process.env.NODE_ENV !== 'production'

function getHotCSS(bundle, devMode) {
    if(!devMode) {
        return bundle;
    }
    return [
        'css-hot-loader',
    ].concat(bundle);
}

const prod = {
    mode: devMode ? 'development' : 'production',
    devtool: devMode ? 'cheap-module-source-map' : 'source-map',
    entry: [
        './ekko-lightbox.js',
        './ekko-lightbox.less'
    ],
    output: {
        path: path.resolve(__dirname, 'dist'),
        filename: devMode ? '[name].js' : 'ekko-lightbox.js'
    },
    module: {
        rules: [{
            test: /\.less$/,
            use: getHotCSS([
                MiniCssExtractPlugin.loader,
                { loader: 'css-loader', options: { sourceMap: true } },
                {
                    loader: 'postcss-loader',
                    options: {
                        ident: 'postcss',
                        sourceMap: true,
                        plugins: (loader) => [
                            require('autoprefixer')({
                                browsers: ['last 2 versions']
                            }),
                            require('cssnano')()
                        ]
                    }
                },
                { loader: 'less-loader', options: { sourceMap: true } }
            ], devMode)
        },
        {
            test: /\.js$/,
            exclude: /(node_modules|bower_components)/,
            use: {
                loader: 'babel-loader',
                options: {
                    presets: [require('babel-preset-env')]
                }
            }
        }]
    },
    plugins: [
        new MiniCssExtractPlugin({
            filename: devMode ? '[name].css' : 'ekko-lightbox.css'
        })
    ],
};

if (!devMode) {
    prod.plugins.push(
        new webpack.BannerPlugin({
            banner:
                'Lightbox for Bootstrap by @ashleydw\n' +
                'https://github.com/ashleydw/lightbox\n' +
                '\n' +
                'License: https://github.com/ashleydw/lightbox/blob/master/LICENSE\n',
            entryOnly: true,
            include: 'ekko-lightbox.js'
        })
    );
} else {
    prod.entry.push('./index.html');
    prod.module.rules.push({
        test: /\.html$/,
        use: "raw-loader"
    });
}

module.exports = prod;