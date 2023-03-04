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

enum Keyword
    Let,
    Func,
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

fn try_id_to_keyw Token t => Option<Keyword>
    if t.type != To::Identifier doremi None<Keyword>()
    if t.value == "let" doremi Keyword::Let
    if t.value == "fn" doremi Keyword::Func
    return None<Keyword>()
;