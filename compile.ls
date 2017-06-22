require! {
    \fs
    \through
    \reactify-ls : \reactify
    \browserify-incremental : \browserifyInc
    \livescript
    \browserify
    \xtend
    \node-sass : \sassc
    \node-watch : \watch
}

basedir = process.cwd!
#dir = "#{basedir}/.compiled"
#fs.mkdir-sync(dir) if not fs.exists-sync(dir)


sass-cache = do 
    path = \./file.sass.cache
    save: (obj)->
       fs.write-file-sync(path, JSON.stringify(obj))
    load: ->
       return {} if not fs.exists-sync(path)
       JSON.parse fs.read-file-sync(path).to-string(\utf8)

sass-c = sass-cache.load!

save = (file, content)->
    console.log "save #{file}"
    fs.write-file-sync(file , content)

setup-watch = (commander)->
    watcher = watch do
        * basedir
        * recursive: yes
          filter: (name)->
             !/(node_modules|\.git)/.test(name) and /\.ls/.test(name)
        * ->
             watcher.close!
             compile commander
compile-file = (input, data)->
  console.log "compile " + input
  code = reactify data
  js = livescript.compile code.ls
  target = input.replace(/\.ls/,\.js)
  save target, js
  code
compile = (commander)->
    console.log "----------------------"
    file = commander.compile
    filename = file.replace(/\.ls/,'')
    return console.error('File is required') if not file?
    bundle = if commander.bundle is yes then \bundle else commander.bundle
    bundle-js =  "#{filename}-#{bundle}.js"
    bundle-css = "#{filename}-#{bundle}.css"
    html = if commander.html is yes then \index else commander.html
    bundle-html = "#{filename}-#{html}.html"
    sass = if commander.sass is yes then \style else commander.sass
    compilesass = if commander.compilesass is yes then \style else commander.compilesass
    sass-c[commander.compile] = sass-c[commander.compile] ? {}
    make-bundle = (file, callback)->
        
        options = 
            basedir: basedir
            paths: ["#{basedir}/node_modules"]
            debug: no 
            commondir: no
            entries: [file]
        b = browserify xtend(browserify-inc.args, options)
        b.transform (file) ->
          data = ''
          write = (buf) -> data += buf
          end = ->
            code =
                compile-file file, data
            if sass?
              save "#{filename}.sass", code.sass
            if compilesass?
              console.log "compile #{filename}.sass"
              sass-conf =
                  data: code.sass
                  indented-syntax: yes
              try
                sass-c[commander.compile][file] = sassc.render-sync(sass-conf).css.to-string(\utf8)
              catch err
                console.error "compile SASS error: #{err.message}"
            @queue livescript.compile code.ls
            @queue null
          through write, end
        browserify-inc b, { cache-file: file + \.cache }
        bundle = b.bundle!
        string = ""
        bundle.on \data, (data)->
          string += data.to-string!
        bundle.on \error, (error)->
          console.error error.message
        _ <-! bundle.on \end
        compiled-sass = sass-c[commander.compile]
        result =
          css: Object.keys(compiled-sass).map(-> compiled-sass[it]).join(\\n)
          js: string
        sass-cache.save sass-c
        callback null, result
    if commander.bundle?
        err, bundlec <-! make-bundle file
        save bundle-js, bundlec.js
        if compilesass?
          save bundle-css, bundlec.css
    if commander.html?
        print = """
        <!DOCTYPE html>
        <html lang="en-us">
          <head>
           <meta charset="utf-8">
           <title>Hello...</title>
           <link rel="stylesheet" type="text/css" href="./#{bundle-css}">
          </head>
          <script type="text/javascript" src="./#{bundle-js}"></script>
        </html>
        """
        save bundle-html, print
    if commander.watch
       setup-watch commander

module.exports = compile