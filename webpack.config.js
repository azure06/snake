/* eslint-disable @typescript-eslint/no-var-requires */
const path = require('path');
const webpack = require('webpack');
const HtmlWebpackPlugin = require('html-webpack-plugin');

module.exports = (env, argv) => ({
    mode: 'none',
    module: {
        rules: [
            {
                enforce: 'pre',
                test: /\.(ts|tsx)$/,
                exclude: /node_modules/,
                loader: 'eslint-loader',
                options: {
                    failOnError: true,
                    fix: true,
                    cache: true,
                },
            },
            {
                test: /\.tsx?$/,
                use: 'ts-loader',
                exclude: /node_modules/,
            },
            {
                test: /elm.js$/,
                use: 'imports-loader?this=>window',
            },
        ],
    },
    resolve: {
        extensions: ['.tsx', '.ts', '.js'],
    },
    plugins: [
        new webpack.DefinePlugin({
            __ENVIRONMENT__: JSON.stringify(argv.mode),
        }),
        new webpack.DefinePlugin({
            __COMMIT_HASH__: JSON.stringify(
                require('child_process')
                    .execSync('git rev-parse --short HEAD')
                    .toString() || '',
            ),
        }),
        new HtmlWebpackPlugin({
            // Also generate a test.html
            filename: 'index.html',
            template: 'public/index.html',
        }),
    ],
    entry: ['./src/main.ts'],
    devtool: 'inline-source-map',
    output: {
        filename: 'index.js',
        path: path.resolve(__dirname, 'dist'),
    },
});
