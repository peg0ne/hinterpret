# hinterpret
 
```haskell
let a = "Hello"
let b = "World"
b = b + "!"
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