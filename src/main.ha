get => print, peekable, stringextensions, files, dictionary
get => tokens, panic
get => Value, Expression, Stmt, Variable, Function
get => Environment
get => tokenizer, evaluater

fn main =>
    if argc != 2
        panic($"Usage {argv[0]} <filename>")
    ;
    select content from read(argv[1]) do run(content)
;

fn run string content =>
    vector<char> program = {}
    foreach i in content do program.push_back(i)
    let environment = Environment()
    let iter = Peekable<char>(program)
    let ast = tokenize(&iter)
    eval_program(environment, Peekable<Token>(ast))
;