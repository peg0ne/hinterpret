fn next_or_panic Peekable<Token> *t => Token
    select token from t->next() doremi token
    panic($"Expected token but arrived at EOF")
;

fn eval_program Environment env, Peekable<Token> ast =>
loop
    let token = next_or_panic(&ast)
    switch token.type
    case To::Identifier dobr eval_id(&env, &ast, token)
    default dobr panic($"Token not allowed in main: {token.as_str()}")
    ;
;
;

fn eval_id Environment *env, Peekable<Token> *ast, Token token =>
    select keyw from try_id_to_keyw(token)
        switch keyw
        case Keyword::Let dobr 
        case Keyword::Func dobr
        default dobr panic($"Unhandled Keyword: {token.as_str()}")
        ;
        return
    ;
    panic($"Unhandled Identifier: {token.as_str()}")
;