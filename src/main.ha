get => print, peekable
get => tokens
get => Value, Expression, Stmt, Variable, Function
get => tokenizer

fn main =>
    let program = "let a = 0\nprint(a)"
    let iter = Peekable<char>(program)
    let ast = tokenize(&iter)
    foreach token in ast do println($"{token.as_str()}")
;