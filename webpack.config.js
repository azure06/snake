/* eslint-disable @typescript-eslint/no-var-requires */
const path = require('path');
const webpack = require('webpack');
const TerserPlugin = require('terser-webpack-plugin');
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
            // {
            //     test: require.resolve('./dist/elm.min.js'),
            //     use: [
            //         {
            //             loader: 'imports-loader',
            //             options: {
            //                 wrapper: {
            //                     thisArg: 'window',
            //                 },
            //             },
            //         },
            //     ],
            // },
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
    optimization: {
        minimize: true,
        minimizer: [
            new TerserPlugin({
                terserOptions: {
                    mangle: true,
                },
                parallel: true,
                test: /\.js(\?.*)?$/i,
            }),
        ],
    },
    entry: ['./src/main.ts'],
    devtool: argv.mode === 'development' ? 'inline-source-map' : undefined,
    output: {
        filename: 'index.js',
        path: path.resolve(__dirname, 'dist'),
    },
});
