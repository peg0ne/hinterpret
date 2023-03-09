get => list
struct ListValue
    List<Value> values = List<Value>()
    ListValue => do return
    ListValue vector<Value> values =>
        this->values = values
    ;
;

struct Value
    Option<double> value_d
    Option<int> value_i
    Option<string> value_s
    Option<bool> value_b
    Option<ListValue> value_l
    Value => do return
    Value int value => do value_i = Some(value)
    Value double value =>
        if (int)value == value do value_i = Some((int)value)
        else do value_d = Some(value)
    ;
    Value string value => do value_s = Some(value)
    Value bool value => do value_b = Some(value)
    Value ListValue value => do value_l = Some(value)
    fn get_type => To
        if value_i.is_some() doremi To::NumberLiteral
        if value_d.is_some() doremi To::NumberLiteral
        if value_s.is_some() doremi To::StringLiteral
        if value_b.is_some() doremi To::BooleanLiteral
        if value_l.is_some() doremi To::ListLiteral
        else doremi To::None
    ;
    fn eval Operator op, Value val =>
        let type = get_type()
        if op == Operator::None
            if type == To::None
                value_l = val.value_l
                value_i = val.value_i
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
            case Operator::At dobr li_at(val)
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
        case To::ListLiteral
            switch op
            case Operator::Add
            case Operator::Sub dobr li_operate(op, val)
            case Operator::At dobr li_at(val)
            default dobr panic($"Operator: {op} not allowed for ListLiterals")
            ;
        ;
    ;
    fn operate Operator op, Value val =>
        let value = value_d.is_some() ? value_d.value_or(0.0) : value_i.value_or(0)
        let operate_val = val.value_d.is_some() ? val.value_d.value_or(0.0) : val.value_i.value_or(0)
        if val.get_type() == To::StringLiteral do panic($"Cannot {op} to {get_type()} with {val.get_type()}")
        if val.get_type() == To::ListLiteral do panic($"Cannot {op} to {get_type()} with {val.get_type()}")
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
        if (int)value == value
            value_d = None<double>()
            value_i = Some((int)value)
        ;
        else
            value_i = None<int>()
            value_d = Some(value)
        ;
    ;
    fn li_operate Operator op, Value val =>
        let list = value_l.value_or(ListValue())
        switch op
        case Operator::Add dobr list.values.add(val)
        case Operator::Sub
            foreach i, value in list.values
                if value.eq(val) dobr list.values.remove(i)
            ;
            break
        ;
        value_l = list
    ;
    fn li_at Value at =>
        select text from value_s
            let as_list = ListValue()
            foreach ch in text do as_list.values.add(string(1, ch))
            value_l = Some(as_list)
        ;
        select list from value_l
            if list.values.len() == 0
                panic($"List contains no values")
            ;
            if at.value_d.is_none() && at.value_i.is_none()
                panic($"Cannot access value at {at.to_eval_str()}")
            ;
            let at_value = at.value_d.value_or(0.0) + at.value_i.value_or(0)
            if at_value > list.values.len()
                panic($"Cannot accces value at {(int)at_value} Index out of range: {list.values.len()}")
            ;
            value_l = None<ListValue>()
            let new_val = list.values.at(at_value)
            switch new_val.get_type()
            case To::StringLiteral dobr this->value_s = new_val.value_s
            case To::NumberLiteral
                this->value_d = new_val.value_d
                this->value_i = new_val.value_i
                break
            case To::ListLiteral dobr this->value_l = new_val.value_l
            case To::BooleanLiteral dobr this->value_b = new_val.value_b
            default panic("Invalid type {new_val.as_str()}")
            ;
        ;
    ;
    fn concat Operator op, Value val =>
        let value = value_s.value_or((string)"")
        let operate_val = val.value_s.value_or((string)"")
        select i_num from val.value_i do operate_val = $"{i_num}"
        select num from val.value_d do operate_val = $"{num}"
        select boolean from val.value_b do operate_val = $"{boolean}"
        select list from val.value_l
            operate_val = "["
            foreach i, val in list.values
                operate_val += val.to_eval_str()
                if i < list.values.len() - 1 do operate_val += ","
            ;
            operate_val += "]"
        ;
        switch op
        case Operator::Add dobr value = $"{value}{operate_val}"
        default dobr panic($"Unhandled Operator: {op} in StringLiteral")
        ;
        value_s = value
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
    fn neq Value v_rhs => bool doremi eq(v_rhs, false)
    fn eq Value v_rhs, bool eq = true => bool
        select i from value_i
            select d_rhs from v_rhs.value_d
                return eq ? i == d_rhs : i != d_rhs
            ;
            select i_rhs from v_rhs.value_i
                return eq ? i == i_rhs : i != i_rhs
            ;
        ;
        select d from value_d
            select d_rhs from v_rhs.value_d
                return eq ? d == d_rhs : d != d_rhs
            ;
            select i_rhs from v_rhs.value_i
                return eq ? d == i_rhs : d != i_rhs
            ;
        ;
        select s from value_s
            select s_rhs from v_rhs.value_s
                return eq ? s == s_rhs : s != s_rhs
            ;
        ;
        select b from value_b
            select b_rhs from v_rhs.value_b
                return eq ? b == b_rhs : b == b_rhs
            ;
        ;
        select l from value_l
            select l_rhs from v_rhs.value_l
                if l.values.len() == l_rhs.values.len()
                    foreach i, item in l_rhs.values
                        if !item.eq(l.values.at(i)) doremi false
                    ;
                    return true
                ;
            ;
        ;
        return false
    ;
    fn as_str => string
        let st = $"{get_type()} "
        select i from value_i do st += $"{i} "
        select d from value_d do st += $"{d} "
        select s from value_s do st += s
        select b from value_b do st += $"{b} "
        select list from value_l
            st = "["
            foreach i, val in list.values
                st += val.to_eval_str()
                if i < list.values.len() - 1 do st += ","
            ;
            st += "] "
        ;
        return st
    ;
    fn to_eval_str => string
        select i from value_i doremi $"{i}"
        select d from value_d
            return (int)d == d ? $"{(int)d}" : String($"{d}").replace(",", ".")
        ;
        select s from value_s doremi s
        select b from value_b doremi $"{b}"
        select list from value_l
            let st = "["
            foreach i, val in list.values
                st += val.to_eval_str()
                if i < list.values.len() - 1 do st += ","
            ;
            st += "]"
            return st
        ;
        doremi "exit"
    ;
;