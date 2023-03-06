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
let skip_next_indent = false
loop
    let token = next_or_panic(&ast)
    if skip_next_indent
        if token.type != To::NL do continue
        else
            select indent from ast.peek()
                if indent.type != To::Indent
                    skip_next_indent = false
                ;
            ;
        ;
    ;
    switch token.type
    case To::FileR dobr eval_r_file(&env, &ast)
    case To::FileW dobr eval_w_file(&env, &ast)
    case To::Identifier dobr eval_id(&env, &ast, token)
    case To::Let dobr eval_let(&env, &ast)
    case To::Print dobr eval_print(&env, &ast)
    case To::PrintNoBr dobr eval_print(&env, &ast, true)
    case To::Read dobr eval_read(&env, &ast)
    case To::If dobr skip_next_indent = !eval_if(&env, &ast)
    case To::Exit dobr exit(1)
    case To::Eval dobr eval_eval(&env, &ast)
    case To::ToNum dobr eval_to_num(&env, &ast)
    case To::NL do break
    case To::Indent do break
    default dobr panic($"Token not allowed in main: {token.as_str()}")
    ;
;
;

fn eval_to_num Environment *env, Peekable<Token> *ast =>
    let id = next_is_type_or_panic(ast, To::Identifier)
    foreach i, var in env->variables
        if var.identifier.value == id.value
            env->variables[i].to_num()
        ;
    ;
;

fn eval_w_file Environment *env, Peekable<Token> *ast => do eval_rw_file(env, ast, false)
fn eval_r_file Environment *env, Peekable<Token> *ast => do eval_rw_file(env, ast, true)
fn eval_rw_file Environment *env, Peekable<Token> *ast, bool read_b =>
    let path = ""
    let path_token = next_or_panic(ast)
    let content = ""
    let content_token = next_or_panic(ast)
    next_is_type_or_panic(ast, To::NL)
    switch path_token.type
    case To::StringLiteral dobr path = path_token.value
    case To::Identifier
        foreach var in env->variables
            if var.identifier.value == path_token.value
                select val from var.value
                    if val.get_type() == To::StringLiteral
                        path = val.value_s.value_or((string)"")
                        break
                    ;
                ;
            ;
        ;
        break
    default dobr panic($"Cannot convert this to a string path {path_token.as_str()}")
    ;
    if !read_b
        switch content_token.type
        case To::StringLiteral dobr content = content_token.value
        case To::Identifier
            foreach var in env->variables
                if var.identifier.value == content_token.value
                    select val from var.value
                        content = val.to_eval_str()
                        break
                    ;
                ;
            ;
            break
        default dobr panic($"Cannot convert this to string content {content_token.as_str()}")
        ;
    ;
    elif content_token.type != To::Identifier
        panic($"Expected Identifier to store read value but got: {content_token.as_str()}")
    ;
    if read_b && path != ""
        select text from read(path)
            content = text
        ;
        foreach i, var in env->variables
            if var.identifier.value == content_token.value
                env->variables[i].value = Value(content)
                return
            ;
        ;
        env->variables.push_back(Variable(
            Token(To::StringLiteral, content_token.value, content_token.line),
            To::StringLiteral,
            Value(content)
        ))
    ;
    elif !read_b && path != "" && content != ""
        write(content, path)
    ;
;

fn eval_id Environment *env, Peekable<Token> *ast, Token token =>
    foreach i,var in env->variables
        if var.identifier.value == token.value
            let eq = next_is_type_or_panic(ast, To::Equals)
            let stmt = collect_stmt(env, ast)
            let value_opt = eval_stmt(env, stmt)
            select value from value_opt
                env->variables[i].value = value
                return
            ;
            return
        ;
    ;
    panic($"Unhandled Identifier: {token.as_str()}")
;

fn eval_if Environment *env, Peekable<Token> *ast => bool
    let stmt = collect_stmt(env, ast)
    let current_value = false
    let combiner = None<Operator>()
    let lhs = None<Value>()
    let op = None<Operator>()
    let rhs = None<Value>()
    foreach part in stmt.expressions
        select value from part.value_va
            if lhs.is_none() do lhs = Some(value)
            elif op.is_none() do panic($"Missing operator in if statement")
            elif rhs.is_none() do rhs = Some(value)
            else do panic($"Missing && || in if")
        ;
        select oper from part.value_op
            let is_combiner = false
            switch oper
            case Operator::And
            case Operator::Or
                combiner = Some(oper)
                is_combiner = true
                break
            ;
            if !is_combiner
                if op.is_none() do op = Some(oper)
                else do panic($"There's already an operator in place in if statement")
            ;
        ;
        if lhs.is_some() && rhs.is_some()
            select oper from op
                switch oper
                case Operator::EqEq
                    select l from lhs
                    select r from rhs
                        select comb from combiner
                            switch comb
                            case Operator::And dobr current_value = current_value && l.eq(r)
                            case Operator::Or dobr current_value = current_value || l.eq(r)
                            ;
                            break
                        ;
                        current_value = l.eq(r)
                    ;;
                    break
                case Operator::NotEq
                    select l from lhs
                    select r from rhs
                        select comb from combiner
                            switch comb
                            case Operator::And dobr current_value = current_value && l.neq(r)
                            case Operator::Or dobr current_value = current_value || l.neq(r)
                            ;
                            break
                        ;
                        current_value = l.neq(r)
                    ;;
                    break
                default dobr panic($"Operator not implemented in if {oper}")
                ;
            ;
            lhs = None<Value>()
            op = None<Operator>()
            rhs = None<Value>()
        ;
    ;
    return current_value
;

fn eval_read Environment *env, Peekable<Token> *ast =>
    let id = next_is_type_or_panic(ast, To::Identifier)
    let input = ""
    cin >> input
    foreach i,var in env->variables
        if var.identifier.value == id.value
            env->variables[i].value = Value(input)
            return
        ;
    ;
    env->variables.push_back(Variable(
        Token(To::StringLiteral, id.value, id.line),
        To::StringLiteral,
        Value(input)
    ))
;

fn eval_print Environment *env, Peekable<Token> *ast => do eval_print(env, ast, false)
fn eval_print Environment *env, Peekable<Token> *ast, bool nolnbr =>
    let print_this = ""
    let id_found = false
    let stmt = collect_stmt(env, ast)
    select value from eval_stmt(env, stmt)
        select b from value.value_b do print_this += $"{b}"
        select s from value.value_s do print_this += $"{s}"
        select d from value.value_d do print_this += $"{d}"
    ;
    if nolnbr do print(print_this)
    else do println(print_this)
;

fn eval_eval Environment *env, Peekable<Token> *ast =>
    let stmt = collect_stmt(env, ast)
    select value from eval_stmt(env, stmt)
        run(value.to_eval_str()+"\n")
    ;
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
        case To::StringLiteral dobr stmt.push_back(to_str_expression(token))
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