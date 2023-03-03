fn add_t vector<Token> *tokens, To type, char value => do add_t(tokens, type, string(1, value))
fn add_t vector<Token> *tokens, To type, string value =>
    tokens->push_back(Token(type, value))
;

fn tokenize Peekable<char> *iter => vector<Token>
    vector<Token> tokens = {}
    let buf = ""
    while iter->peek().is_some()
        select ch from iter->next()
            switch ch
            case '-'
            case '/'
            case '*'
            case '+' dobr add_t(&tokens, To::Operator, ch)
            case '=' dobr add_t(&tokens, To::Equals, ch)
            case '(' dobr add_t(&tokens, To::LParen, ch)
            case ')' dobr add_t(&tokens, To::RParen, ch)
            case '"'
                buf = ""
                loop
                    select s from iter->next()
                        if s == '"' do break
                        else doco buf += string(1, s)
                    ;
                    break
                ;
                add_t(&tokens, To::StringLiteral, ch)
                break
            default
                buf = ""
                if isalpha(ch)
                    while isalpha(ch)
                        buf += string(1, ch)
                        ch = iter->peek().value_or('\n')
                        if isalpha(ch) do iter->next()
                    ;
                    add_t(&tokens, To::Identifier, buf)
                ;
                elif isdigit(ch)
                    while isdigit(ch) || ch == '.'
                        buf += string(1, ch)
                        ch = iter->peek().value_or('\n')
                        if isdigit(ch) || ch == '.' do iter->next()
                    ;
                    add_t(&tokens, To::NumberLiteral, buf)
                ;
            ;
        ;
    ;
    return tokens
;