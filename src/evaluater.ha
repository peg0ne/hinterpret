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

fn eval_program Environment *env, Peekable<Token> ast =>
let skip_next_indent = false
loop
    if ast.peek().is_none() do return
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
        if eval_id(env, &ast, token) do return
        break
    case To::Let dobr eval_let(env, &ast)
    case To::Print dobr eval_print(env, &ast)
    case To::PrintNoBr dobr eval_print(env, &ast, true)
    case To::Read dobr eval_read(env, &ast)
    case To::If dobr skip_next_indent = !eval_if(env, &ast)
    case To::Exit dobr exit(1)
    case To::Eval dobr eval_eval(env, &ast)
    case To::ToNum dobr eval_to_num(env, &ast)
    case To::SysCall dobr eval_sys_call(env, &ast)
    case To::Func dobr eval_func(env, &ast)
    case To::Loop dobr eval_loop(env, &ast)
    case To::NL do break
    case To::Indent do break
    default dobr panic($"Token not allowed in main: {token.as_str()}")
    ;
;
;

fn eval_to_num Environment *env, Peekable<Token> *ast =>
    let id = next_is_type_or_panic(ast, To::Identifier)
    select var from env->try_get_variable_ptr(id.literal) dore var->to_num()
    panic($"Cannot find variable {id.as_str()}")
;

fn eval_loop Environment *env, Peekable<Token> *ast =>
    let start = 0
    let end = 0
    let start_token = next_or_panic(ast)
    let end_token = next_or_panic(ast)
    switch start_token.type
    case To::NumberLiteral
        select num from String(start_token.literal).to_num()
            start = (int)num
        ;
        break
    case To::Identifier
        select var from env->try_get_variable_ptr(start_token.literal)
            var->to_num()
            select num from var->to_num() dobr start = (int)num
        ;
        panic($"Cannot convert {start_token.as_str()} to a number")
        break
    default panic($"Expected number or identifier got: {start_token.as_str()}")
    ;
    switch end_token.type
    case To::NumberLiteral
        select num from String(end_token.literal).to_num()
            end = (int)num
        ;
        break
    case To::Identifier
        select var from env->try_get_variable_ptr(end_token.literal)
            select num from var->to_num() dobr end = (int)num
        ;
        panic($"Cannot convert {end_token.as_str()} to a number")
        break
    default panic($"Expected number or identifier got: {end_token.as_str()}")
    ;
    let nl = next_is_type_or_panic(ast, To::NL)
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
    if stmts.size() < 1 do panic($"Loop contains nothing")
    let peekable_ast = Peekable<Token>(stmts)
    while start < end
        eval_program(env, peekable_ast)
        start++
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
    case To::StringLiteral dobr path = path_token.literal
    case To::Identifier
        select var from env->try_get_variable(path_token.literal)
            select val from var.value
                if val.get_type() == To::StringLiteral
                    path = val.value_s.value_or("")
                    break
                ;
            ;
        ;
        break
    default dobr panic($"Cannot convert this to a string path {path_token.as_str()}")
    ;
    if !read_b
        switch content_token.type
        case To::StringLiteral dobr content = content_token.literal
        case To::Identifier
            select var from env->try_get_variable(content_token.literal)
                select val from var.value
                    content = val.to_eval_str()
                    break
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
        select var from env->try_get_variable_ptr(content_token.literal)
            var->value = Value(content)
            return
        ;
        env->variables.add(content_token.literal, Variable(
            Token(To::StringLiteral, content_token.literal, content_token.line),
            To::StringLiteral,
            Value(content)
        ))
    ;
    elif !read_b && path != "" && content != ""
        write(content, path)
    ;
;

fn eval_sys_call Environment *env, Peekable<Token> *ast =>
    let output = ""
    let cmd = ""
    let cmd_token = next_or_panic(ast)
    switch cmd_token.type
    case To::StringLiteral dobr cmd = cmd_token.literal
    case To::Identifier
        select var from env->try_get_variable(cmd_token.literal)
            select val from var.value
                if val.get_type() == To::StringLiteral
                    cmd = val.value_s.value_or("")
                ;
            ;
        ;
        break
    default dobr panic($"Cannot convert this to a string command {cmd_token.as_str()}")
    ;
    if cmd != ""
        let outputs = system_output(cmd)
        foreach i,line in outputs
            line =  String(line).strip_end()
            if i == 0 do output += line
            else do output += "\n" + line
        ;
    ;
    let variable_token = next_or_panic(ast)
    switch variable_token.type
    case To::Identifier do break
    case To::NL do return
    default panic($"Cannot store output to: {variable_token.as_str()}")
    ;
    select var from env->try_get_variable_ptr(variable_token.literal)
        var->value = Value(output)
        return
    ;
    env->variables.add(variable_token.literal, Variable(
        Token(To::StringLiteral, variable_token.literal, variable_token.line),
        To::StringLiteral,
        Value(output)
    ))
;

fn eval_id Environment *env, Peekable<Token> *ast, Token token => bool
    select var from env->try_get_variable_ptr(token.literal)
        let eq = next_or_panic(ast)
        if eq.type == To::Equals
            let stmt = collect_stmt(env, ast)
            let value_opt = eval_stmt(env, stmt)
            select value from value_opt
                var->value = value
            ;
        ;
        return token.literal == "return"
    ;
    select fun from env->try_get_function(token.literal)
        vector<Token> program = {}
        foreach fun_arg in fun.args
            let arg = next_or_panic(ast)
            program.push_back(Token(To::Let, "let", 0))
            program.push_back(Token(To::Identifier, fun_arg.identifier.literal, 0))
            program.push_back(Token(To::Equals, "=", 0))
            switch arg.type
            case To::StringLiteral
                select val from to_str_expression(arg).value_va
                    program.push_back(Token(val.get_type(), val.to_eval_str(), arg.line))
                ;
                break
            case To::NumberLiteral
                select val from to_num_expression(arg).value_va
                    program.push_back(Token(val.get_type(), val.to_eval_str(), arg.line))
                ;
                break
            case To::Identifier
                select val from to_value_expression(env, arg).value_va
                    program.push_back(Token(val.get_type(), val.to_eval_str(), arg.line))
                ;
                break
            default dobr panic($"Unhandled token in stmt {arg.as_str()}")
            ;
            program.push_back(Token(To::NL, "\n", arg.line))
        ;
        foreach t in fun.statements do program.push_back(t)
        let new_env = Environment()
        new_env.functions = env->functions
        eval_program(&new_env, Peekable<Token>(program))
        let arg = next_or_panic(ast)
        if arg.type == To::NL do return false
        if arg.type == To::Identifier
            select r from new_env.try_get_variable("return")
                select output from env->try_get_variable_ptr(arg.literal)
                    output->value = r.value
                    output->type = r.type
                    return false
                ;
                env->variables.add(arg.literal, r)
            ;
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
    select var from env->try_get_variable_ptr(id.literal)
        var->value = Value(input)
        return
    ;
    env->variables.add(id.literal, Variable(
        Token(To::StringLiteral, id.literal, id.line),
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
    select var from env->try_get_variable(id.literal)
        panic($"Id '{var.identifier.literal}' Is already assigned at line {var.identifier.line}")
    ;
    let eq = next_is_type_or_panic(ast, To::Equals)
    let stmt = collect_stmt(env, ast)
    select value from eval_stmt(env, stmt)
        env->variables.add(id.literal, Variable(id, value.get_type(), value))
    ;
    env->variables.add(id.literal, Variable(id))
;

fn eval_func Environment *env, Peekable<Token> *ast =>
    let id = next_is_type_or_panic(ast, To::Identifier)
    vector<Variable> args = {}
    vector<Token> stmts = {}
    stmts.push_back(Token(To::Let, "let", 0))
    stmts.push_back(Token(To::Identifier, "return", 0))
    stmts.push_back(Token(To::Equals, "=", 0))
    stmts.push_back(Token(To::StringLiteral, "", 0))
    stmts.push_back(Token(To::NL, "\n", 0))
    select var from env->try_get_function(id.literal)
        panic($"Id '{var.identifier.literal}' Is already defined at line {var.identifier.line}")
    ;
    loop
        let arg = next_or_panic(ast)
        if arg.type == To::NL do break
        if arg.type != To::Identifier do panic($"Expected Identifier or = got: {arg.as_str()}")
        args.push_back(Variable(arg))
    ;
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
    if stmts.size() < 2 do panic($"No statements found in function {id.as_str()}")
    env->functions.add(id.literal, Function(
        id,
        args,
        stmts
    ))
;

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