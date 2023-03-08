# hinterpret
 
```haskell
let a = "Hello"
let b = "World"
b += "!"
print RED + a + " " + b + "!" + RESET

filer "ver.txt" version
tonum version
print GREEN + "Version: " + RESET + version 
print "Update version? " + YELLOW + "(y/n)" + RESET
printnobr RED + "> " + RESET
read input
if input == "y"
    | version = version + 0.1
    | print GREEN + "Updated version to: " + RESET + version
    | filew "ver.txt" version

exit
```

### syscalls
alternative to read write
```haskell
sys "echo 'some text' > text.txt"
sys "cat text.txt" output
print output
```

### functions
```haskell
fn add v t 
    | return = a + t

add 1 2 output
print output
```

### caching functions
these functions will cache the result
they will skip processing the function if cached result is found and just return the cached result
```haskell
cfn add v t 
    | return = a + t

add 1 2 output
print output
```

### loops
```haskell
let i = 0
loop 0 15
    | print i
    | i += 1
```

### lists
prints [Hello, ,World,!]
```haskell
let li = []
li += "Hello"
li += " "
li += "World"
li += "!"
print li
```
remove from list
prints [1,3]
```haskell
let li = []
li += 1
li += 2
li += 3
li -= 2
print li
```

access values
```haskell
let li = []
li += 1
li += 2
li += 3
let el = li at 1
print el
print li at 1
```