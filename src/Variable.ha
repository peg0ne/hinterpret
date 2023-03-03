struct Variable
    Token identifier
    Token type
    Option<Value> value
    Variable Token identifier, Token type, Option<Value> value =>
        this->identifier = identifier
        this->type = type
        this->value = value
    ;
;