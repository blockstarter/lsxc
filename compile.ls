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
    \fix-indents
    \chalk : { red, yellow, gray, green }
    \express
    \vm
}


basedir = process.cwd!
compileddir = "#{basedir}/.compiled"

base-title = (colored, symbol, text)-->
  text = "[#{colored symbol}] #{colored text}"
  max = 40 - text.length
  if max <= 0 then text
  else text + [0 to max].map(-> " ").join('')

title = base-title green, "✓"
error = base-title red, "x"
warn  = base-title yellow, "!"




fs.mkdir(compileddir) if not fs.exists-sync(compileddir)

save = (file, content)->
    save-origin "#{compileddir}/#{file}" , content
save-origin = (file, content)->
    console.log "#{title 'save'} #{file}"
    fs.write-file-sync file , content

setup-watch = (commander)->
    return if setup-watch.init
    console.log warn "watcher started..."
    setup-watch.init = yes
    watcher = watch do
        * basedir
        * recursive: yes
          filter: (name)->
             !/(node_modules|\.git)/.test(name) and /\.(ls|json|js)/.test(name)
        * (evt, name)->
             return if setup-watch.disabled
             console.log "#{warn 'changed'} #name"
             setup-watch.disabled = yes
             #watcher.close!
             err <-! compile commander
             <-! set-timeout _, 500
             setup-watch.disabled = no
server-start = (commander)->
  return if server-start.init
  server-start.init = yes
  app = express!
  app.use(express.static(compileddir)) 
  port =   if commander.nodestart is yes then 8080 else commander.nodestart
  start = ->
    app.listen port, ->
      console.log("#{warn 'node started'} port #{port}")
  script = new vm.Script("(#{start.to-string!})()" )
  context = new vm.create-context( { port, app, console, warn } )
  script.run-in-context context
  port
  
compile-file = (input, data)->
  console.log "#{title 'compile'} #{input}" 
  code = reactify data
  state =
    js: null
  try 
    state.js = livescript.compile code.ls
  catch err 
    state.err = err.message
    errorline = err.message.match(/line ([0-9]+)/).1 ? 0
    
    lines = code.ls.split(\\n)
    for index of lines 
       if index is errorline
         lines[index] = lines[index] + "       <<< #{red err.message}"
       else 
         lines[index] = gray lines[index]
    console.log ([] ++ lines).join(\\n)
  #target = input.replace(/\[^\/]+.ls/,\.js)
  #save target, state.js
  { code.ls, code.sass, state.js, state.err}
compile = (commander, cb)->
    console.log "----------------------"
    cb2 = (err, data)->
      if err?
         console.log "#{red 'Error'} err"
      cb? err, data
    file = commander.compile
    sass-cache = do
      path = "#{compileddir}/#{file}.sass.cache"
      save: (obj)->
         fs.write-file-sync(path, JSON.stringify(obj))
      load: ->
         return {} if not fs.exists-sync(path)
         JSON.parse fs.read-file-sync(path).to-string(\utf8)
    sass-c = sass-cache.load!
    #return if file.index-of('.ls') is -1
    filename = file.replace /\.ls/,''
    return cb2 'File is required' if not file?
    bundle = if commander.bundle is yes then \bundle else commander.bundle
    bundle-js =  "#{filename}-#{bundle}.js"
    bundle-css = "#{filename}-#{bundle}.css"
    html = if commander.html is yes then \index else commander.html
    bundle-html = "#{filename}-#{html}.html"
    sass = if commander.sass is yes then \style else commander.sass
    compilesass = if commander.compilesass is yes then \style else commander.compilesass
    sass-c[commander.compile] = sass-c[commander.compile] ? {}
    make-bundle = (file, callback)->
        console.log "#{title 'start main file'} #file"
        options = 
            basedir: basedir
            paths: ["#{basedir}/node_modules"]
            debug: no 
            commondir: no
            entries: [file]
        b = browserify xtend(browserify-inc.args, options)
        b.transform (file) ->
          json = file.match(/([a-z-0-9_]+)\.json$/)?1
          js = file.match(/([a-z-0-9_]+)\.js$/)?1
          filename = file.match(/([a-z-0-9_]+)\.ls$/)?1
          data = ''
          write = (buf) -> data += buf
          
            
          end = ->
            t = @
            send = (data)->
                t.queue data 
                t.queue null
            return send data if json?
            return send data if js?
            code =
                compile-file file, data
            if sass?
              save "#{filename}.sass", code.sass
            if commander.fixindents
              indented = fix-indents data
              if data isnt indented
                 console.log "#{title 'fix indents'} #file"
                 save-origin file, indented
            if compilesass?
              console.log "#{title 'compile'} #{filename}.sass"
              if code.sass.length > 0
                sass-conf =
                    data: code.sass
                    indented-syntax: yes
                try
                  sass-c[commander.compile][file] = sassc.render-sync(sass-conf).css.to-string(\utf8)
                catch err
                  console.error "#{error 'err compile sass'}  #{yellow err.message}"
              else 
                sass-c[commander.compile][file] = ""
            save "#{filename}.js", code.js
            send code.js
          through write, end
        browserify-inc b, { cache-file:  "#{compileddir}/#{file}.cache" }
        bundle = b.bundle!
        string = ""
        bundle.on \data, (data)->
          string += data.to-string!
        bundle.on \error, (err)->
          console.log "#{ error 'bundle err' } #{err.message ? err}"
        _ <-! bundle.on \end
        compiled-sass = sass-c[commander.compile]
        result =
          css: Object.keys(compiled-sass).map(-> compiled-sass[it]).join(\\n)
          js: string
        sass-cache.save sass-c
        callback null, result
    if commander.bundle?
      err, bundlec <-! make-bundle file
      return cb2 err if err? 
      if not commander.putinhtml?
         save bundle-js, bundlec.js
      if compilesass? and not commander.putinhtml?
         save bundle-css, bundlec.css
      
      css-in =  | commander.putinhtml => """<style>#{bundlec.css}</style>"""
                | _ => """ <link rel="stylesheet" type="text/css" href="./#{bundle-css}">  """
      html-in = | commander.putinhtml => """<script>#{bundlec.js}</script>"""
                | _ => """<script type="text/javascript" src="./#{bundle-js}"></script>"""
      if commander.html?
          print = """
          <!DOCTYPE html>
          <html lang="en-us">
            <head>
             <meta charset="utf-8">
             <title>#{filename}</title>
             #{css-in}
            </head>
            #{html-in}
          </html>
          """
          save bundle-html, print
      if commander.nodestart?
         server-start commander
      if commander.watch
         setup-watch commander
      cb2 null, "success"
module.exports = compile