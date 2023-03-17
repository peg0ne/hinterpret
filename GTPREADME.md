# Documentation for <programming language name>

## Syntax

-   No semicolons at the end of each line.
-   Blocks are determined by the indentation marker '|'.
-   Function call arguments are not enclosed in parenthesis.
-   Variables are mutable always and can change type depending on what value it holds.

## Data Types

-   `number`: represents a numerical value.
-   `boolean`: represents a Boolean value, which can be either `true` or `false`.
-   `string`: represents a sequence of characters.
-   `list`: represents a collection of values, which can be of different types.

## Control Flow

### If Statement

-   There is only `if` statement. There are no `else` or `else if`.
-   Conditional expressions can use the `&&` and `||` operators.

### For Loop

-   For loops can be used to iterate over a range of values or a list.

### Infinite Loop

-   Infinite loops can be created using the `loop` keyword.

### Break Statement

-   A `break` statement can be used to exit a loop.

## Functions

-   Functions are defined using the `fn` keyword followed by the function name and its arguments.
-   A function can return a value using the `return` keyword.
-   Functions can also be defined as caching functions using the `cfn` keyword.

## Built-In Functions

-   `print`: prints a message to the console with a newline character at the end.
-   `printnobr`: prints a message to the console without a newline character at the end.
-   `filer`: reads a file.
-   `filew`: writes to a file.
-   `tonum`: converts a value to a number.
-   `read`: reads user input from the command line.
-   `eval`: evaluates a string as source code for this language and runs it.
-   `sys`: provides access to make system calls.

## Built-In Constants

-   `BLACK`, `RED`, `GREEN`, `BLUE`, `YELLOW`, `CYAN`, `MAGENTA`, `WHITE`, `BLACKBG`, `REDBG`, `GREENBG`, `BLUEBG`, `YELLOWBG`, `CYANBG`, `MAGENTABG` - provide easy color formatting when printing
-   `RESET` - provides the reset keyword to stop - color formatting
-   `COLS` - provides terminal width
-   `LINES` - provides terminal height

## Operators

-   There is no operator precedence. Operations are evaluated left to right.

## Error Handling

-   There is no error handling.

## Examples

### Hello World

```python
print "Hello, World!"
```

### Adding Two Numbers

```python
fn add a b
| return = a + b

add 1 2 output
print output
```

### Pseudo-Dictionary

```python
fn getfromdict dict key
| let dictlen = key len
| dictlen /= 2
| let item
| let valueindex
| for i dictlen
| | item = dict at i
| | valueindex = i + 1
| | if item == key
| | | return = dict at valueindex

let dict = []
dict += "key"
dict += 1

getfromdict "key" out
print out
```

### Importing Functions

```python
import "helper"

helperfunction argument output
```

### Limitations

Limitations

-   Operator precedence does not exist here. Operations are evaluated left to right.
-   Variables are dynamically typed, which can make code more error-prone.
-   There is no error handling, which can make debugging difficult. but interpreter will most likely tell you what's going wrong
