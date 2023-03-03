enum To
    Equals,
    LParen,
    RParen,
    Identifier,
    StringLiteral,
    NumberLiteral,
    BooleanLiteral,
    Operator,
    None,
; 

enum Operator
    Add,
    Sub,
    Mul,
    Div,
    And,
    Or,
;
 
struct Token
    To type
    string value
    Token => do return
    Token To type => do this->type = type
    Token To type, char value =>
        this->type = type
        this->value = string(1, value)
    ;
    Token To type, string value =>
        this->type = type
        this->value = value
    ;
    fn as_str => string
        return $"{type} -> {value}"
    ;
;