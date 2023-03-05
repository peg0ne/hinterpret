enum To
    Equals,
    LParen,
    RParen,
    Identifier,
    StringLiteral,
    NumberLiteral,
    BooleanLiteral,
    Operator,
    NL,
    Print,
    Let,
    None,
;

enum Operator
    Add,
    Sub,
    Mul,
    Div,
    And,
    Or,
    None,
;
 
struct Token
    To type
    string value
    int line
    Token => do return
    Token To type, int line =>
        this->type = type
        this->line = line
    ;
    Token To type, char value, int line =>
        this->type = type
        this->value = string(1, value)
        this->line = line
    ;
    Token To type, string value, int line =>
        this->type = type
        this->value = value
        this->line = line
    ;
    fn as_str => string
        return $"{type}: '{value}' at Line: {line}"
    ;
;