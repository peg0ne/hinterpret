enum To
    SubEquals,
    AddEquals,
    DivEquals,
    MulEquals,
    Equals,
    LParen,
    RParen,
    LBox,
    RBox,
    Identifier,
    Indent,
    StringLiteral,
    NumberLiteral,
    BooleanLiteral,
    ListLiteral,
    Operator,
    NL,
    Print,
    PrintNoBr,
    Read,
    FileR,
    FileW,
    Let,
    If,
    Import,
    Func,
    CachedFunc,
    AsyncFunc,
    Random,
    Exit,
    Break,
    Eval,
    Loop,
    For,
    ToNum,
    SysCall,
    None,
;

enum Operator
    Add,
    Sub,
    Mul,
    Div,
    Not,
    And,
    Less,
    More,
    LessEq,
    MoreEq,
    At,
    Len,
    Or,
    EqEq,
    NotEq,
    None,
;
 
struct Token
    To type
    string literal
    int line
    Token => do return
    Token To type, char value, int line =>
        this->type = type
        this->literal = string(1, value)
        this->line = line
    ;
    Token To type, string value, int line =>
        this->type = type
        this->literal = value
        this->line = line
    ;
    fn as_str => string doremi $"{type}: '{literal}' at Line: {line}"
;