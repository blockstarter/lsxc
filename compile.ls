require! {
    \fs 
    \reactify-ls : \reactify
    \browserify-incremental : \browserifyInc
    \livescript
    \browserify
    \xtend
    \commander
}

module.exports = (commander)->
    file = commander.compile
    return console.error('File is required') if not file?
    target = commander.target ? file
    bundle = if commander.bundle is yes then \bundle else commander.bundle
    html = if commander.html is yes then \index else commander.html
    
    input = "#{file}.ls"
    console.log "Compile " + input
    code = reactify fs.read-file-sync(input).to-string(\utf-8)
    js = livescript.compile code
    
    fs.write-file-sync("#{target}.js", js)
    
    basedir = process.cwd!
    
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
    console.log "Current Directory " + basedir
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
