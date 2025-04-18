const path = require('path')

module.exports = {
  entry: './src/index.ts', // entry point for your diagram code
  output: {
    filename: 'webview.js',
    path: path.resolve(__dirname, 'pack'), // as required by sprotty-vscode
    libraryTarget: 'umd',
  },
  resolve: {
    extensions: ['.ts', '.tsx', '.js'],
  },
  module: {
    rules: [
      {
        test: /\.tsx?$/,
        use: {
          loader: 'ts-loader',
          options: {
            transpileOnly: false,
            compilerOptions: {
              experimentalDecorators: true
            }
          }
        },
        exclude: /node_modules/
      }
    ]
  },
  mode: 'production',
};
