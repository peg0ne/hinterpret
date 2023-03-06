struct Variable
    Token identifier
    Option<To> type
    Option<Value> value
    Variable => do return
    Variable Token identifier =>
        this->identifier = identifier
        this->type = To::None
        this->value = None<Value>()
    ;
    Variable Token identifier, To type, Value value =>
        this->identifier = identifier
        this->type = type
        this->value = Some(value)
    ;
    fn to_num =>
        type = To::StringLiteral
        select val from value
            let stripped = String(val.to_eval_str()).strip()
            select num from String(stripped).to_num()
                value = Some(Value(num))
                return
            ;
            value = Some(Value(0.0))
            return
        ;
        panic($"Unable to convert to num {identifier.as_str()}")
    ;
;