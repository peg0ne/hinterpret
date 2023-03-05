struct Expression
    Option<Value> value_va
    Option<Operator> value_op
    Expression => do return
    Expression Value value => do value_va = Some(value)
    Expression Operator value => do value_op = Some(value)
;

fn to_num_expression Token t => Expression
    select num from String(t.value).to_num()
        return Expression(Value(num))
    ;
    panic($"Expected a Number got {t.as_str()}")
    return Expression()
;

fn to_op_expression Token t => Expression
    if t.value == "+" doremi Expression(Operator::Add)
    elif t.value == "-" doremi Expression(Operator::Sub)
    elif t.value == "*" doremi Expression(Operator::Mul)
    elif t.value == "/" doremi Expression(Operator::Div)
    elif t.value == "!" doremi Expression(Operator::Not)
    elif t.value == "&&" doremi Expression(Operator::And)
    elif t.value == "||" doremi Expression(Operator::Or)
    elif t.value == "==" doremi Expression(Operator::EqEq)
    elif t.value == "!=" doremi Expression(Operator::NotEq)
    panic($"Unhandeled Operator: {t.as_str()}")
    return Expression()
;

fn to_str_expression Token t => Expression
    return Expression(Value(t.value))
;