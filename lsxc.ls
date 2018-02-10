#!/usr/bin/env node
require! {
  \commander
  \chalk : {green, yellow}
  \./compile.js
}

opt = yellow(' Optional')

pack = require('./package.json')


commander
  .version(pack.version)
  .option('-c, --compile [filename]', 'Main File. Without extension')
  .option('-p, --putinhtml [filename]', 'Put bundle.js and bundle.css content into html file' + opt)
  .option('-s, --sass [filename]', 'Result File (style.sass).' + opt)
  .option('-n, --nodestart [port]', 'Start nodejs to serve generated html files.' + opt)
  .option('-f, --fixindents', 'Fix indents in source files' + opt)
  .option('-j, --javascrypt', 'Encrypt resulted javascript' + opt)
  .option('-k, --compilesass [filename]', 'Result File (style.css).' + opt)
  .option('-w, --watch', 'Watch changes in folder and recompile.' + opt)
  .option('-l, --livereload', 'Starts webserver and refreshes page when file changed (Not Implemented).' + opt)
  .option('-i, --ssr', 'Isomorphic Server side rendering. Generate Express app (Not Implemented).' + opt)
  .option('-b, --bundle [filename]', 'Generate bundle.js' + opt)
  .option('-h, --html', 'Generate HTML included bundle.js for demo.' + opt)
  .option('-t, --template [filename]', 'Use custom html template for inline html' + opt)
  .parse(process.argv)

compile commander
  
