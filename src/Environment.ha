struct Environment
    Dictionary<string, Variable> variables = Dictionary<string, Variable>()
    Dictionary<string, Function*> functions = Dictionary<string, Function*>()
    Environment => do return
    fn try_get_variable string id => Option<Variable>
        return variables.try_get_value(id)
    ;
    fn try_get_variable_ptr string id => Option<Variable*>
        return variables.try_get_value_ptr(id)
    ;
    fn try_get_function string id => Option<Function*>
        return functions.try_get_value(id)
    ;
    fn destruct =>
        foreach key in functions.keys()
            select f from functions.try_get_value(key)
                delete(f)
            ;
        ;
    ;
;

fn to_value_expression Environment *env, Token t => Expression
    let val = None<Value>()
    select var from env->try_get_variable(t.literal)
        val = var.value
    ;
    select num from String(t.literal).to_num()
        return Value(num)
    ;
    if val.is_none() do panic($"Cannot access value of {t.as_str()}")
    return Expression(val.value_or(Value()))
;