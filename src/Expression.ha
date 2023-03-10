struct Expression
    Option<Value> value_va
    Option<Operator> value_op
    Expression => do return
    Expression Value value => do value_va = Some(value)
    Expression Operator value => do value_op = Some(value)
;

fn to_num_expression Token t => Expression
    let s = String(t.literal)
    if s.contains(".")
        while s.ends_with("00") do s.remove_back(1)
    ;
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
    elif t.literal == "<" doremi Expression(Operator::Less)
    elif t.literal == ">" doremi Expression(Operator::More)
    elif t.literal == "<=" doremi Expression(Operator::LessEq)
    elif t.literal == ">=" doremi Expression(Operator::MoreEq)
    elif t.literal == "!" doremi Expression(Operator::Not)
    elif t.literal == "&&" doremi Expression(Operator::And)
    elif t.literal == "||" doremi Expression(Operator::Or)
    elif t.literal == "==" doremi Expression(Operator::EqEq)
    elif t.literal == "!=" doremi Expression(Operator::NotEq)
    elif t.literal == "at" doremi Expression(Operator::At)
    elif t.literal == "len" doremi Expression(Operator::Len)
    panic($"Unhandled Operator: {t.as_str()}")
    return Expression()
;

fn to_list_expression Token t => Expression
    let s = String(t.literal).replace("[", "")
    s = String(s).replace("]", "")
    let values = String(s).split(',')
    let lival = ListValue()
    foreach val in values
        if val == "" do continue
        let num = String(val).to_num()
        if val =|= "false" : "true"
            lival.values.add(Value(val == "true"))
        ;
        elif num.is_some()
            lival.values.add(Value(num.value_or(0)))
        ;
        else
            lival.values.add(Value(val))
        ;
    ;
    return Expression(Value(lival))
;

fn to_str_expression Token t => Expression
    return Expression(Value(t.literal))
;