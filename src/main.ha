get => print, peekable, stringextensions, files, dictionary, ncurses
get => tokens, panic
get => Value, Expression, Stmt, Variable, Function
get => Environment
get => tokenizer, evaluater

fn main =>
    if argc < 2
        panic($"Usage {argv[0]} <filename>")
    ;
    srand(time(NULL))
    select content from read(argv[1]) do run(content, argc, argv, true)
;

fn run string content, int argc, char **argv, bool should_exit => Environment
    vector<char> program = {}
    foreach i in content do program.push_back(i)
    let environment = Environment()
    environment.assign_var(Token(To::Identifier, "argc", 0), Value(argc-2))
    let argv_list = ListValue()
    for i until argc
        if i < 2 do continue
        else do argv_list.values.add(Value((string)argv[i]))
    ;
    environment.assign_var(Token(To::Identifier, "argv", 0), Value(argv_list))
    let iter = Peekable<char>(program)
    let ast = tokenize(&iter)
    eval_program(&environment, Peekable<Token>(ast), should_exit)
    return environment
;