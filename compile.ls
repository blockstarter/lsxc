require! {
    \fs
    \glob
    \reactify-ls : \reactify
    \browserify-incremental : \browserifyInc
    \livescript
    \browserify
    \xtend
    \node-sass : \sassc
    \node-watch : \watch
}
basedir = process.cwd!

save = (file, content)->
    console.log "Save #{file}"
    fs.write-file-sync(file, content)

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
  console.log "Compile " + input
  code = reactify data
  js = livescript.compile code.ls
  target = input.replace(/\.ls/,\.js)
  save target, js
  code
compile = (commander)->
    console.log "----------------------"
    file = commander.compile
    return console.error('File is required') if not file?
    bundle = if commander.bundle is yes then \bundle else commander.bundle
    html = if commander.html is yes then \index else commander.html
    sass = if commander.sass is yes then \style else commander.sass
    compilesass = if commander.compilesass is yes then \style else commander.compilesass
    make-bundle = (file, callback)->
        styles = []
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
            styles.push code.sass
            @queue code.ls
            @queue null
          through write, end
        browserify-inc b, {cache-file: file + ".cache"}
        bundle = b.bundle!
        string = ""
        bundle.on \data, (data)->
          string += data.to-string!
        bundle.on \error, (error)->
             #console.error error
        _ <-! bundle.on \end
        result =
          sass: styles.join(\\n)
          bundle: string
        callback null, result
    if commander.bundle?
        err, bundlec <-! make-bundle file
        return console.error err if err?
        save "#{bundle}.js", bundlec.bundle
        if sass?
          save "#{sass}.sass", bundlec.sass
          if compilesass?
            console.log "Compile SASS"
            state =
              css: ""
            try 
               state.css = 
                 sassc.render-sync do
                   data: bundlec.sass
                   indented-syntax: yes
               save "#{compilesass}.css", state.css.css
            catch err
               console.error "Compile SASS Error #{err.message ? err}"
          
    if commander.html?
        print = '''
        <!DOCTYPE html>
        <html lang="en-us">
          <head>
           <meta charset="utf-8">
           <title>Hello...</title>
           <link rel="stylesheet" type="text/css" href="./style.css">
          </head>
          <script type="text/javascript" src="./bundle.js"></script>
        </html>
        '''
        save "#{html}.html", print
    if commander.watch
       setup-watch commander

module.exports = compile