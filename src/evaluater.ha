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

fn eval_program Environment *env, Peekable<Token> ast, bool should_exit => bool
let skip_next_indent = false
loop
    if ast.peek().is_none() doremi false
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
    case To::FileR dobr eval_r_file(env, &ast)
    case To::FileW dobr eval_w_file(env, &ast)
    case To::Identifier
        if eval_id(env, &ast, token) doremi true
        break
    case To::Let dobr eval_let(env, &ast)
    case To::Print dobr eval_print(env, &ast)
    case To::PrintNoBr dobr eval_print(env, &ast, true)
    case To::Random dobr eval_random(env, &ast)
    case To::Read dobr eval_read(env, &ast)
    case To::If dobr skip_next_indent = !eval_if(env, &ast)
    case To::Exit
        if should_exit do exit(1)
        else doremi true
        break
    case To::Eval dobr eval_eval(env, &ast, false)
    case To::Import dobr eval_eval(env, &ast, true)
    case To::ToNum dobr eval_to_num(env, &ast)
    case To::SysCall dobr eval_sys_call(env, &ast)
    case To::Func dobr eval_func(env, &ast, false)
    case To::CachedFunc dobr eval_func(env, &ast, true)
    case To::Loop dobr eval_loop(env, &ast)
    case To::For dobr eval_for(env, &ast)
    case To::NL
    case To::Indent do break
    case To::Break doremi true
    default dobr panic($"Token not allowed in main: {token.as_str()}")
    ;
;
return false
;

fn eval_to_num Environment *env, Peekable<Token> *ast =>
    let id = next_is_type_or_panic(ast, To::Identifier)
    select var from env->try_get_variable_ptr(id.literal) dore var->to_num()
    panic($"Cannot find variable {id.as_str()}")
;

fn eval_random Environment *env, Peekable<Token> *ast =>
    let min_i = (int)token_to_number(env, next_or_panic(ast))
    let max_i = (int)token_to_number(env, next_or_panic(ast))
    let out = next_is_type_or_panic(ast, To::Identifier)
    let random = (rand() % max_i) + min_i
    env->assign_var(out, Value(random))
;

fn eval_loop Environment *env, Peekable<Token> *ast =>
    next_is_type_or_panic(ast, To::NL)
    let stmts = collect_indent_stmt(ast)
    if stmts.size() < 1 do panic($"Loop contains nothing")
    loop
        if eval_program(env, stmts, false) do break
    ;
;

fn eval_for Environment *env, Peekable<Token> *ast =>
    let start_token = next_or_panic(ast)
    let is_id = start_token.type == To::Identifier
    let existed = env->try_get_variable(start_token.literal).is_some()
    let start = existed ? (int)token_to_number(env, start_token) : 0
    let end = (int)token_to_number(env, next_or_panic(ast))
    let nl = next_is_type_or_panic(ast, To::NL)
    let stmts = collect_indent_stmt(ast)
    if stmts.size() < 1 do panic($"Loop contains nothing")
    while start < end
        if is_id
            env->assign_var(start_token, Value(start))
        ;
        if eval_program(env, stmts, false) do break
        start++
    ;
    if !existed
        env->variables.remove(start_token.literal)
    ;
;

fn eval_w_file Environment *env, Peekable<Token> *ast => do eval_rw_file(env, ast, false)
fn eval_r_file Environment *env, Peekable<Token> *ast => do eval_rw_file(env, ast, true)
fn eval_rw_file Environment *env, Peekable<Token> *ast, bool read_b =>
    let path = token_to_string(env, next_or_panic(ast), true)
    let content_or_out_token = next_or_panic(ast)
    let content = read_b ? "" : token_to_string(env, content_or_out_token, false)
    next_is_type_or_panic(ast, To::NL)
    if path == "" do panic($"Specified path is empty")
    if read_b
        if content_or_out_token.type != To::Identifier
            panic($"Expected Identifier to store read value but got: {content_or_out_token.as_str()}")
        ;
        select text from read(path) do content = text
        env->assign_var(content_or_out_token, Value(content))
    ;
    elif content != "" do write(content, path)
;

fn eval_sys_call Environment *env, Peekable<Token> *ast =>
    let output = ""
    let cmd = token_to_string(env, next_or_panic(ast), true)
    let variable_token = next_or_panic(ast)
    if cmd == "" do panic($"Command cannot be executed since it's empty")
    if variable_token.type == To::NL
        let x = system(cmd)
        return
    ;
    let outputs = system_output(cmd)
    foreach i,line in outputs
        line =  String(line).strip_end()
        if i == 0 do output += line
        else do output += "\n" + line
    ;
    env->assign_var(variable_token, Value(output))
;

fn eval_id Environment *env, Peekable<Token> *ast, Token token => bool
    select var from env->try_get_variable_ptr(token.literal)
        select eq from ast->peek()
            if eq.type == To::Equals
                next_or_panic(ast)
                let stmt = collect_stmt(env, ast)
                let value_opt = eval_stmt(env, stmt)
                select value from value_opt
                    var->value = value
                ;
            ;
            elif eq.type =|= (To::AddEquals) : (To::SubEquals) : (To::DivEquals) : (To::MulEquals)
                next_or_panic(ast)
                select lhs from var->value
                    let stmt = collect_stmt(env, ast)
                    let value_opt = eval_stmt(env, stmt)
                    switch eq.type
                    case To::AddEquals
                        select value from value_opt
                            lhs.eval(Operator::Add, value)
                        ;
                        break
                    case To::SubEquals
                        select value from value_opt
                            lhs.eval(Operator::Sub, value)
                        ;
                        break
                    case To::DivEquals
                        select value from value_opt
                            lhs.eval(Operator::Div, value)
                        ;
                        break
                    case To::MulEquals
                        select value from value_opt
                            lhs.eval(Operator::Mul, value)
                        ;
                        break
                    ;
                    var->value = Some(lhs)
                ;
            ;
        ;
        return token.literal == "return"
    ;
    select fun from env->try_get_function(token.literal)
        vector<Token> program = {}
        let cache_str = ""
        foreach fun_arg in fun->args
            let arg = next_or_panic(ast)
            program.push_back(Token(To::Let, "let", 0))
            program.push_back(Token(To::Identifier, fun_arg.identifier.literal, 0))
            program.push_back(Token(To::Equals, "=", 0))
            switch arg.type
            case To::StringLiteral
                select val from to_str_expression(arg).value_va
                    program.push_back(Token(val.get_type(), val.to_eval_str(), arg.line))
                    cache_str += val.to_eval_str()
                ;
                break
            case To::NumberLiteral
                select val from to_num_expression(arg).value_va
                    program.push_back(Token(val.get_type(), val.to_eval_str(), arg.line))
                    cache_str += val.to_eval_str()
                ;
                break
            case To::Identifier
                select val from to_value_expression(env, arg).value_va
                    program.push_back(Token(val.get_type(), val.to_eval_str(), arg.line))
                    cache_str += val.to_eval_str()
                ;
                break
            default dobr panic($"Unhandled token in stmt {arg.as_str()}")
            ;
            program.push_back(Token(To::NL, "\n", arg.line))
        ;
        if fun->allow_cache && fun->cache.contains(cache_str)
            select var from fun->cache.try_get_value(cache_str)
                let arg = next_or_panic(ast)
                if arg.type == To::NL do return false
                env->assign_var(arg, var.value.value_or(Value()))
                return false
            ;
        ;
        foreach t in fun->statements do program.push_back(t)
        let new_env = Environment()
        new_env.functions = env->functions
        eval_program(&new_env, Peekable<Token>(program), false)
        let arg = next_or_panic(ast)
        if arg.type == To::NL do return false
        select r from new_env.try_get_variable("return")
            if fun->allow_cache do fun->cache.add(cache_str,r)
            env->assign_var(arg, r.value.value_or(Value()))
        ;
        return false
    ;
    panic($"Unhandled Identifier: {token.as_str()}")
    return false
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
                case Operator::NotEq
                case Operator::More
                case Operator::Less
                case Operator::MoreEq
                case Operator::LessEq 
                    current_value = combined_proc_condition(lhs, rhs, combiner, current_value, oper)
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
    env->assign_var(id, Value(input))
;

fn eval_print Environment *env, Peekable<Token> *ast => do eval_print(env, ast, false)
fn eval_print Environment *env, Peekable<Token> *ast, bool nolnbr =>
    let print_this = ""
    let stmt = collect_stmt(env, ast)
    select value from eval_stmt(env, stmt)
        print_this += value.to_eval_str()
    ;
    if nolnbr do print(print_this)
    else do println(print_this)
;

fn eval_eval Environment *env, Peekable<Token> *ast, bool fetch_funcs =>
    let stmt = collect_stmt(env, ast)
    select value from eval_stmt(env, stmt)
        if fetch_funcs
            select program from read($"{value.to_eval_str()}.hi")
                let new_env = run(program, 0, {}, false)
                env->functions.steal(new_env.functions)
                return
            ;
            panic($"Unable to import {value.to_eval_str()}.hi")
        ;
        else
            let new_env = run(value.to_eval_str()+"\n", 0, {}, false)
            new_env.destruct()
        ;
    ;
;

fn eval_let Environment *env, Peekable<Token> *ast =>
    let id = next_is_type_or_panic(ast, To::Identifier)
    select var from env->try_get_variable(id.literal)
        panic($"Id '{var.identifier.literal}' Is already assigned at line {var.identifier.line}")
    ;
    let eq = next_is_type_or_panic(ast, To::Equals)
    let stmt = collect_stmt(env, ast)
    select value from eval_stmt(env, stmt) dore env->assign_var(id, value)
    env->variables.add(id.literal, Variable(id))
;

fn eval_func Environment *env, Peekable<Token> *ast, bool allow_cache =>
    let id = next_is_type_or_panic(ast, To::Identifier)
    vector<Variable> args = {}
    vector<Token> stmts = {}
    stmts.push_back(Token(To::Let, "let", 0))
    stmts.push_back(Token(To::Identifier, "return", 0))
    stmts.push_back(Token(To::Equals, "=", 0))
    stmts.push_back(Token(To::StringLiteral, "", 0))
    stmts.push_back(Token(To::NL, "\n", 0))
    select var from env->try_get_function(id.literal)
        panic($"Id '{var->identifier.literal}' Is already defined at line {var->identifier.line}")
    ;
    loop
        let arg = next_or_panic(ast)
        if arg.type == To::NL do break
        if arg.type != To::Identifier do panic($"Expected Identifier or = got: {arg.as_str()}")
        args.push_back(Variable(arg))
    ;
    let indented = collect_indent_stmt(ast)
    while indented.peek().is_some() do stmts.push_back(indented.next().value_or(Token()))
    if stmts.size() < 2 do panic($"No statements found in function {id.as_str()}")
    env->functions.add(id.literal, new Function(
        id,
        args,
        stmts,
        allow_cache
    ))
;

fn collect_indent_stmt Peekable<Token> *ast => Peekable<Token>
    vector<Token> stmts = {}
    loop
        let token = next_or_panic(ast)
        if token.type != To::Indent do break
        loop
            token = next_or_panic(ast)
            stmts.push_back(token)
            if token.type == To::NL do break
        ;
        select t from ast->peek()
            if t.type != To::Indent do break
        ;
    ;
    return Peekable<Token>(stmts)
;

fn collect_stmt Environment *env, Peekable<Token> *ast => Stmt
    vector<Expression> stmt = {}
    loop
        let token = next_or_panic(ast)
        switch token.type
        case To::StringLiteral dobr stmt.push_back(to_str_expression(token))
        case To::NumberLiteral dobr stmt.push_back(to_num_expression(token))
        case To::ListLiteral dobr stmt.push_back(to_list_expression(token))
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
            case To::StringLiteral
            case To::NumberLiteral
            case To::BooleanLiteral
            case To::ListLiteral dobr value.eval(current_op, val)
            default dobr panic($"Unhandled type {val_type}")
            ;
        ;
        select op from expr.value_op 
            current_op = op
            if current_op == Operator::Len
                if type == To::ListLiteral
                    select list from value.value_l
                        value = Value(list.values.len())
                    ;
                ;
                elif type == To::StringLiteral
                    select text from value.value_s
                        value = Value((int)text.size())
                    ;
                ;
                else do panic($"Cannot do operation len on {type}")
            ;
            continue
        ;
    ;
    return value
;