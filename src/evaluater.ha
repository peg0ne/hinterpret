fn next_or_panic Peekable<Token> *t => Token
    select token from t->next() doremi token
    panic($"<- Ended")
    return Token()
;

fn next_is_type_or_panic Peekable<Token> *t, To type => Token
    let token = next_or_panic(t)
    if token.type == type doremi token
    else do panic($"Expected {type} got: {token.as_str()}")
    return Token()
;

fn eval_program Environment env, Peekable<Token> ast =>
loop
    let token = next_or_panic(&ast)
    switch token.type
    case To::Identifier dobr eval_id(&env, &ast, token)
    case To::Let dobr eval_let(&env, &ast)
    case To::Print dobr eval_print(&env, &ast)
    case To::NL do break
    default dobr panic($"Token not allowed in main: {token.as_str()}")
    ;
;
;

fn eval_id Environment *env, Peekable<Token> *ast, Token token =>
    panic($"Unhandled Identifier: {token.as_str()}")
;

fn eval_print Environment *env, Peekable<Token> *ast =>
    let print_this = ""
    let id_found = false
    next_is_type_or_panic(ast, To::LParen)
    loop
        let token = next_or_panic(ast)
        if token.type == To::RParen do break
        switch token.type
        case To::NumberLiteral
        case To::BooleanLiteral
        case To::StringLiteral dobr print_this += token.value
        case To::Identifier
            id_found = false
            foreach v in env->variables
                if v.identifier.value == token.value
                    id_found = true
                    let value = v.value.value_or(Value())
                    select b from value.value_b do print_this += $"{b}"
                    select s from value.value_s do print_this += $"{s}"
                    select d from value.value_d do print_this += $"{d}"
                    break
                ;
            ;
            if id_found == false do panic($"Identifier: {token.as_str()} not found in program")
            break
        default dobr panic($"Unhandled token in print {token.as_str()}")
        ;
    ;
    println(print_this)
;

fn eval_let Environment *env, Peekable<Token> *ast =>
    let id = next_is_type_or_panic(ast, To::Identifier)
    foreach var in env->variables
        if id.value == var.identifier.value
            panic($"Id '{var.identifier.value}' Is already assigned at line {var.identifier.line}")

        ;
    ;
    let eq = next_is_type_or_panic(ast, To::Equals)
    let stmt = collect_stmt(env, ast)
    select value from eval_stmt(env, stmt)
        env->variables.push_back(Variable(id, value.get_type(), value))
    ;
    env->variables.push_back(Variable(id))
;
fn eval_func Environment *env, Peekable<Token> *ast => do panic("eval_func Not Implemented")

fn collect_stmt Environment *env, Peekable<Token> *ast => Stmt
    vector<Expression> stmt = {}
    loop
        let token = next_or_panic(ast)
        switch token.type
        case To::NumberLiteral dobr stmt.push_back(to_num_expression(token))
        case To::Operator dobr stmt.push_back(to_op_expression(token))
        case To::Identifier dobr stmt.push_back(to_value_expression(env, token))
        case To::NL doremi Stmt(stmt)
        default dobr panic($"Unhandled token in stmt {token.as_str()}")
        ;
    ;
    return Stmt(stmt)
;
fn eval_stmt Environment *env, Stmt stmt => Option<Value>
    let value = Value()
    To type = To::None
    Operator current_op = Operator::None
    foreach expr in stmt.expressions
        select val from expr.value_va
            let val_type = val.get_type()
            if type != To::None && current_op == Operator::None
                panic($"Expected Operator got Value: {val_type}")
            ;
            if type == To::None do type = val_type
            switch val_type
            case To::StringLiteral dobr value.eval(current_op, val)
            case To::NumberLiteral dobr value.eval(current_op, val)
            case To::BooleanLiteral dobr value.eval(current_op, val)
            default dobr panic($"Unhandled type {val_type}")
            ;
        ;
        select op from expr.value_op doco current_op = op
    ;
    return value
;