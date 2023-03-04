get => print, peekable
get => tokens, panic
get => Value, Expression, Stmt, Variable, Function
get => Environment
get => tokenizer, evaluater

fn main =>
    let program = "let a = 0\nprint(a)"
    let environment = Environment()
    let iter = Peekable<char>(program)
    let ast = tokenize(&iter)
    foreach token in ast do println($"{token.as_str()}")
    eval_program(environment, Peekable<Token>(ast))
;