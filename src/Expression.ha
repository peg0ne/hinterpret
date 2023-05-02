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
    let op match t.literal
        "+" => doremi Operator::Add
        "-" => doremi Operator::Sub
        "*" => doremi Operator::Mul
        "/" => doremi Operator::Div
        "<" => doremi Operator::Less
        ">" => doremi Operator::More
        "<=" => doremi Operator::LessEq
        ">=" => doremi Operator::MoreEq
        "!" => doremi Operator::Not
        "&&" => doremi Operator::And
        "||" => doremi Operator::Or
        "==" => doremi Operator::EqEq
        "!=" => doremi Operator::NotEq
        "at" => doremi Operator::At
        "len" => doremi Operator::Len
        _ => 
            panic($"Unhandled Operator: {t.as_str()}")
            Operator::Add
        ;
    ;
    return Expression(op)
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