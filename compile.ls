require! {
    \fs 
    \reactify-ls : \reactify
    \browserify-incremental : \browserifyInc
    \livescript
    \browserify
    \xtend
    \commander
    \colors
}

opt = ' Optional'.yellow
commander
  .version('0.0.1')
  .option('-f, --file [filename]', 'Main File. Without extension')
  .option('-t, --target [filename]', 'Result File (result.js).' + opt)
  .option('-b, --bundle [filename]', 'Generate bundle.js' + opt)
  .option('-h, --html', 'Generate HTML included bundle.js for demo.' + opt)
  .parse(process.argv)



file = commander.file
return console.error('File is required') if not file?
target = commander.target ? file
bundle = commander.bundle ? \bundle
html = commander.html ? \index

input = "#{file}.ls"
console.log "Compile ".yellow + input
code = reactify fs.read-file-sync(input).to-string(\utf-8)
js = livescript.compile code

fs.write-file-sync("#{target}.js", js)

basedir = __dirname

make-bundle = (file, callback)->
    options = 
        basedir: basedir
        paths: ["#{basedir}/node_modules"]
        debug: no 
        commondir: no
        entries: [file]
    b = browserify(xtend(browserify-inc.args, options)) 
    browserify-inc b, {cacheFile: file + ".cache"}
    bundle = b.bundle!
    string = ""
    data <-! bundle.on \data
    bundle.on \error, (error)->
         console.error error
    string += data.to-string!
    _ <-! bundle.on \end
    callback null, string

return if not commander.bundle?
console.log "Current Directory ".yellow + basedir
err, bundle <-! make-bundle "#{target}.js"
fs.write-file-sync("#{bundle}.js", bundle)


return if not commander.html?
print = '''
<!DOCTYPE html>
<html lang="en-us">
  <head>
   <meta charset="utf-8">
   <title>Hello...</title>
  </head>
  <script type="text/javascript" src="./bundle.js"></script>
</html>

'''

fs.write-file-sync "#{html}", print
