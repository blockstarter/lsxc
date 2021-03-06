# LSX Compiler

![logo](http://res.cloudinary.com/nixar-work/image/upload/v1516572404/lsx-logo.jpg)

* Compile LiveScript + Pug + SASS + React into JavaScript and CSS bundles
* Describe the styles, logic and layout of your app in one file (component style)
* Use benefits of indented languages
* Build React DOM in functional style
* Use fast compiler

## Demo 

[![Demo](https://img.youtube.com/vi/Z5NuIIHBsqg/0.jpg)](https://youtu.be/Z5NuIIHBsqg)

## News 

```
We can pay for improvements when we accept your pull requests
```

```
We are hiring - please contract a.stegno@gmail.com
```

```
Join to collaborate https://ide.c9.io/askucher/lsxc
```

## Install

```sh
npm i lsxc -g

#next modules we use for demo:
npm i react react-dom mobx mobx-react --save 
```

## Example 

### Code (file.ls)

```Livescript
require! {
  \mobx-react : { observer }
  \mobx : { observable }
  \react-dom : { render }
  \react
}

.btn
  color: red
  padding-left: 5px
  &:hover
    color: orange

btn = ({click, text})->
    a.pug.btn(target='blank' on-click=click) #{text} 

input = ({store})->
  handle-enter-click = (event) -> 
    return if event.key-code isnt 13 
    store.todos.push text: event.target.value
    event.target.value = ''
  input.pug(on-key-down=handle-enter-click)  

Main = observer ({store})->
  remove = (todo, _)-->
      index = store.todos.index-of todo
      return if index < 0
      store.todos.splice 1, index
  .pug
    h3.pug Tasks
    for todo in store.todos
      .pug 
        span.pug #{todo.text}
        span.pug
          btn {text: 'Remove', click: remove todo}
    input {store}
    hr.pug 

window.onload = ->
  store = observable do
      todos:
        * text: 'Do dishes'
        ...
  render do
    Main.pug(store=store)
    document.document-element
```

### Compile 

```sh
lsxc -skhbc file.ls
```

### Help

To see all available options for `lsxc` run next command:

```sh
lsxc --help
```

## Run programmatically

### JavaScript

```Javascript
let lsxc = require('lsxc');

let opts = {
    file: "filename",
    target: "resultname",
    bundle: "bundle",
    html: "index"
};

lsxc(opts);
```

## Use a custom HTML template 

### 1. Create a file `template.html`

```html
<!DOCTYPE html>
<html lang="en-us">
  <head>
    <meta charset="utf-8">
    <title>The Perfect App</title>
    <dynamicCSS/>
  </head>
  <body>
    <dynamicHTML/>
  </body>
</html>
```

### 2. Then compile an app:

```sh
lscx -h -t ./template.html
```

