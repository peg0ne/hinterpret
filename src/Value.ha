struct Value
    Option<double> value_d
    Option<string> value_s
    Option<bool> value_b
    Value => do return
    Value double value => do value_d = Some(value)
    Value string value => do value_s = Some(value)
    Value bool value => do value_b = Some(value)
    fn get_type => To
        if value_d.is_some() doremi To::NumberLiteral
        if value_s.is_some() doremi To::StringLiteral
        if value_b.is_some() doremi To::BooleanLiteral
        else doremi To::None
    ;
    fn eval Operator op, Value val =>
        let type = get_type()
        if op == Operator::None
            if type == To::None
                value_d = val.value_d
                value_s = val.value_s
                value_b = val.value_b
                return
            ;
            panic($"Cannot assign value without operator")
        ;
        switch type
        case To::NumberLiteral
            switch op
            case Operator::Add
            case Operator::Sub
            case Operator::Mul
            case Operator::Div dobr operate(op, val)
            default dobr panic($"Operator: {op} not allowed for NumberLiterals")
            ;
            break
        case To::StringLiteral
            switch op
            case Operator::Add dobr concat(op, val)
            default dobr panic($"Operator: {op} not allowed for StringLiterals")
            ;
            break
        case To::BooleanLiteral
            switch op
            case Operator::And dobr
            case Operator::Or dobr condition(op, val)
            default dobr panic($"Operator: {op} not allowed for BooleanLiterals")
            ;
            break
        ;
    ;
    fn operate Operator op, Value val =>
        let value = value_d.value_or(0.0)
        let operate_val = val.value_d.value_or(0.0)
        if val.get_type() == To::StringLiteral do panic($"Cannot {op} to {get_type()} with {val.get_type()}")
        if val.get_type() == To::BooleanLiteral
            operate_val = val.value_b.value_or(false) ? 1.0 : 0.0
        ;
        switch op
        case Operator::Add dobr value += operate_val
        case Operator::Sub dobr value -= operate_val
        case Operator::Mul dobr value *= operate_val
        case Operator::Div dobr value /= operate_val
        default dobr panic($"Unhandled Operator: {op} in NumberLiteral")
        ;
        value_d = Some(value)
    ;
    fn concat Operator op, Value val =>
        let value = value_s.value_or((string)"")
        let operate_val = val.value_s.value_or((string)"")
        select num from val.value_d do operate_val = $"{num}"
        select boolean from val.value_b do operate_val = $"{boolean}"
        switch op
        case Operator::Add dobr $"{value}{operate_val}"
        default dobr panic($"Unhandled Operator: {op} in StringLiteral")
        ;
    ;
    fn condition Operator op, Value val =>
        let value = value_b.value_or(false)
        let operate_val = val.value_b.value_or(false)
        if val.get_type() != To::BooleanLiteral do panic($"Cannot handle Boolean expression with {val.get_type()}")
        switch op
        case Operator::And dobr value = value && operate_val
        case Operator::Or dobr value = value || operate_val
        default dobr panic($"Unhandled Operator: {op} in BooleanLiteral")
        ;
    ;
    fn as_str => string
        let st = $"{get_type()} "
        select d from value_d do st += $"{d} "
        select s from value_s do st += s
        select b from value_b do st += $"{b} "
        return st
    ;
;