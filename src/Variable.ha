struct Variable
    Token identifier
    Option<To> type
    Option<Value> value
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
;