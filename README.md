# hinterpret
 
```
let a = "Hello"
let b = "World"
print RED + a + " " + b + "!" + RESET

let version = 0.1
print GREEN + "Version: " + RESET + version 
print "Update version? " + YELLOW + "(y/n)" + RESET
printnobr RED + "> " + RESET
read input
if input == "y"
    | let newversion = version + 0.1
    | print GREEN + "Updated version to: " + RESET + newversion

exit
```