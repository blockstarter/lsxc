# lsxc 
### Compile Livescript + Pug + React into Javascript Bundle

Install 

```
npm i lsxc -g
```

Run 

```
lsxc --help
```


Run Programmatically

Javascript 
```
lsxc = require('lsxc');

options = {
    file: "filename",
    target: "resultname",
    bundle: "bundle",
    html: "index"
}

lsxc(options)

```
