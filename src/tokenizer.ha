fn add_t vector<Token> *tokens, To type, char value, int line => do add_t(tokens, type, string(1, value), line)
fn add_t vector<Token> *tokens, To type, string value, int line =>
    tokens->push_back(Token(type, value, line))
;

fn tokenize Peekable<char> *iter => vector<Token>
    vector<Token> tokens = {}
    let buf = ""
    let line = 1
    while iter->peek().is_some()
        select ch from iter->next()
            switch ch
            case ' ' do break
            case '-'
            case '/'
            case '*'
            case '+' dobr add_t(&tokens, To::Operator, ch, line)
            case '=' dobr add_t(&tokens, To::Equals, ch, line)
            case '(' dobr add_t(&tokens, To::LParen, ch, line)
            case ')' dobr add_t(&tokens, To::RParen, ch, line)
            case '\n' dobr add_t(&tokens, To::NL, ch, line++)
            case '"'
                buf = ""
                loop
                    select s from iter->next()
                        if s == '"' do break
                        else doco buf += string(1, s)
                    ;
                    break
                ;
                add_t(&tokens, To::StringLiteral, ch, line)
                break
            default
                buf = ""
                if isalpha(ch)
                    while isalpha(ch)
                        buf += string(1, ch)
                        ch = iter->peek().value_or('\n')
                        if isalpha(ch) do iter->next()
                    ;
                    if buf == "print" do add_t(&tokens, To::Print, buf, line)
                    elif buf == "let" do add_t(&tokens, To::Let, buf, line)
                    else do add_t(&tokens, To::Identifier, buf, line)
                ;
                elif isdigit(ch)
                    while isdigit(ch) || ch == '.'
                        buf += string(1, ch)
                        ch = iter->peek().value_or('\n')
                        if isdigit(ch) || ch == '.' do iter->next()
                    ;
                    add_t(&tokens, To::NumberLiteral, buf, line)
                ;
                else do panic($"Unhandled character found: {string(1,ch)}")
                break
            ;
        ;
    ;
    return tokens
;