struct Environment
    vector<Variable> variables = {}
    vector<Function> functions = {}
    Environment => do return
;

fn to_value_expression Environment *env, Token t => Expression
    let val = None<Value>()
    foreach var in env->variables
        if var.identifier.value == t.value
            val = var.value
            break
        ;
    ;
    if val.is_none() do panic($"Cannot access value of {t.as_str()}")
    return Expression(val.value_or(Value()))
;