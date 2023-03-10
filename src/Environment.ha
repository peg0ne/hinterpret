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
    fn try_get_value string id => Option<Value>
        select var from try_get_variable(id) doremi var.value
        return None<Value>()
    ;
    fn try_get_number_value string id => Option<double>
        select val from try_get_value(id)
            if val.get_type() == To::NumberLiteral
                return Some(val.number_value())
            ;
        ;
        return None<double>()
    ;
    fn assign_var Token id, Value v =>
        if id.type != To::Identifier do panic($"Cannot store value into {id.as_str()}")
        select var from try_get_variable_ptr(id.literal)
            var->type = Some(v.get_type())
            var->value = Some(v)
            return
        ;
        variables.add(id.literal, Variable(
            id,
            v.get_type(),
            v
        ))
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

fn token_to_number Environment *env, Token t => double
    switch t.type
    case To::NumberLiteral doremi (int)(String(t.literal).to_num().value_or(0.0))
    case To::Identifier
        select num from env->try_get_number_value(t.literal)
            return num
        ;
        panic($"Variable is not type of number literal {t.as_str()}")
        break
    default panic($"Expected number or identifier got: {t.as_str()}")
    ;
    return 0
;

fn token_to_string Environment *env, Token t, bool strict => string
    switch t.type
    case To::StringLiteral doremi t.literal
    case To::Identifier
        select var from env->try_get_variable(t.literal)
            select val from var.value
                if val.get_type() == To::StringLiteral
                    return val.value_s.value_or("")
                ;
                elif !strict
                    return val.to_eval_str()
                ;
            ;
        ;
        break
    default dobr panic($"Cannot convert this to a string {t.as_str()}")
    ;
    return ""
;

fn combined_proc_condition Option<Value> lhs, Option<Value> rhs, Option<Operator> comb, bool current, Operator op => bool
    select l from lhs
        select r from rhs
            select c from comb
                switch c
                case Operator::And doremi current && l.proc_condition(op, r)
                case Operator::Or doremi current || l.proc_condition(op, r)
                ;
                panic($"Invalid combiner in condition {c}")
            ;
            return l.proc_condition(op, r)
        ;
    ;
    return false
;