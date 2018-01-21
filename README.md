![logo](http://res.cloudinary.com/nixar-work/image/upload/v1516572404/lsx-logo.jpg)

* Compile Livescript + Pug + SASS + React into Javascript/Css Bundle
* Store your style, logic and layout in one file
* Use benefits of indented languages

### Demo 

[![Demo](https://img.youtube.com/vi/Z5NuIIHBsqg/0.jpg)](https://youtu.be/Z5NuIIHBsqg)

### News 

```
Do not think that's it is abandoned. We use it daily. We do not update it because it is stable.
```

```
We are hiring - please contact a.stegno@gmail.com 
```

### Install

```
npm i lsxc -g

#for demo
npm i react react-dom mobx mobx-react --save 
```

### Example 

#### Code (file.ls)

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

#### Compile 

```
lsxc -skhbc file.ls

```

#### Help

```
lsxc --help
```



### Run Programmatically

#### Javascript

```Javascript
lsxc = require('lsxc');

options = {
    file: "filename",
    target: "resultname",
    bundle: "bundle",
    html: "index"
}

lsxc(options)

```
