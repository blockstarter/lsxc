require! {
  \mobx-react : { observer }
  \mobx : { observable }
  \react-dom : { render }
  \react
}

ul = ->
  ul.vv.test
    for i in [1 to 10]
     li.vv: .vv
       switch i
         case 1 
          .vv(title="text#{i}") #{i}
         else
          .vv test

btn = ({click, text})->
    style =
        color: \red
        padding-left: \5px
    a.vv.btn(target='blank' on-click=click style=style) #{text} 

input = ({store})->
  handle-enter-click = (event) -> 
    return if event.key-code isnt 13 
    store.todos.push text: event.target.value
    event.target.value = ''
  input.vv(on-key-down=handle-enter-click)  

Main = observer ({store})->
  remove = (todo, _)-->
      index = store.todos.index-of todo
      return if index < 0
      store.todos.splice 1, index
  .vv
    h3.vv Tasks
    for todo in store.todos
      .vv 
        span.vv #{todo.text}
        span.vv
          btn {text: 'Remove', click: remove todo}
    input {store}
    hr.vv 
    ul!
    

window.onload = ->
  store = observable do
      todos:
        * text: 'Do dishes'
        ...
  render do
    Main.vv(store=store)
    document.body.append-child document.create-element \app