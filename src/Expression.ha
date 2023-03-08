struct Expression
    Option<Value> value_va
    Option<Operator> value_op
    Expression => do return
    Expression Value value => do value_va = Some(value)
    Expression Operator value => do value_op = Some(value)
;

fn to_num_expression Token t => Expression
    let s = String(t.literal)
    while s.ends_with("00") do s.remove_back(1)
    select num from s.to_num()
        return Expression(Value(num))
    ;
    panic($"Expected a Number got {t.as_str()}")
    return Expression()
;

fn to_op_expression Token t => Expression
    if t.literal == "+" doremi Expression(Operator::Add)
    elif t.literal == "-" doremi Expression(Operator::Sub)
    elif t.literal == "*" doremi Expression(Operator::Mul)
    elif t.literal == "/" doremi Expression(Operator::Div)
    elif t.literal == "!" doremi Expression(Operator::Not)
    elif t.literal == "&&" doremi Expression(Operator::And)
    elif t.literal == "||" doremi Expression(Operator::Or)
    elif t.literal == "==" doremi Expression(Operator::EqEq)
    elif t.literal == "!=" doremi Expression(Operator::NotEq)
    elif t.literal == "at" doremi Expression(Operator::At)
    panic($"Unhandled Operator: {t.as_str()}")
    return Expression()
;

fn to_list_expression Token t => Expression
    return Expression(Value(ListValue()))
;

fn to_str_expression Token t => Expression
    return Expression(Value(t.literal))
;