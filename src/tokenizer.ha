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
            case '(' dobr add_t(&tokens, To::LParen, ch, line)
            case ')' dobr add_t(&tokens, To::RParen, ch, line)
            case '\n' dobr add_t(&tokens, To::NL, ch, line++)
            case ':' dobr add_t(&tokens, To::Indent, ch, line++)
            case '-'
            case '/'
            case '*'
            case '+' 
                select eq from iter->peek()
                    if eq == '='
                        iter->next()
                        switch ch
                        case '-' dobr add_t(&tokens, To::SubEquals, "-=", line)
                        case '+' dobr add_t(&tokens, To::AddEquals, "+=", line)
                        case '/' dobr add_t(&tokens, To::DivEquals, "/=", line)
                        case '*' dobr add_t(&tokens, To::MulEquals, "*=", line)
                        ;
                        break
                    ;
                ;
                add_t(&tokens, To::Operator, ch, line)
                break
            case '&'
                select eq from iter->peek()
                    if eq == '&'
                        iter->next()
                        add_t(&tokens, To::Operator, "&&", line)
                        break
                    ;
                ;
                add_t(&tokens, To::Operator, ch, line)
                break
            case '|'
                select eq from iter->peek()
                    if eq == '|'
                        iter->next()
                        add_t(&tokens, To::Operator, "||", line)
                        break
                    ;
                ;
                add_t(&tokens, To::Indent, ch, line)
                break
            case '!'
                select eq from iter->peek()
                    if eq == '='
                        iter->next()
                        add_t(&tokens, To::Operator, "!=", line)
                        break
                    ;
                ;
                add_t(&tokens, To::Operator, ch, line)
                break
            case '='
                select eq from iter->peek()
                    if eq == '='
                        iter->next()
                        add_t(&tokens, To::Operator, "==", line)
                        break
                    ;
                ;
                add_t(&tokens, To::Equals, ch, line)
                break
            case '\''
                buf = ""
                loop
                    select s from iter->next()
                        if s == '\'' do break
                        else doco buf += string(1, s)
                    ;
                    break
                ;
                add_t(&tokens, To::StringLiteral, buf, line)
                break
            case '"'
                buf = ""
                loop
                    select s from iter->next()
                        if s == '"' do break
                        else doco buf += string(1, s)
                    ;
                    break
                ;
                add_t(&tokens, To::StringLiteral, buf, line)
                break
            case '['
                select r from iter->peek()
                    if r == ']'
                        iter->next()
                        add_t(&tokens, To::ListLiteral, "[]", line)
                        break
                    ;
                ;
                panic("Did you mean to initialize a list? please check that it looks like this '[]'")
                break
            default
                buf = ""
                if isalpha(ch)
                    while isalpha(ch)
                        buf += string(1, ch)
                        ch = iter->peek().value_or('\n')
                        if isalpha(ch) do iter->next()
                    ;
                    if buf == "at" do add_t(&tokens, To::Operator, buf, line)
                    elif buf == "print" do add_t(&tokens, To::Print, buf, line)
                    elif buf == "printnobr" do add_t(&tokens, To::PrintNoBr, buf, line)
                    elif buf == "let" do add_t(&tokens, To::Let, buf, line)
                    elif buf == "read" do add_t(&tokens, To::Read, buf, line)
                    elif buf == "if" do add_t(&tokens, To::If, buf, line)
                    elif buf == "exit" do add_t(&tokens, To::Exit, buf, line)
                    elif buf == "eval" do add_t(&tokens, To::Eval, buf, line)
                    elif buf == "filer" do add_t(&tokens, To::FileR, buf, line)
                    elif buf == "filew" do add_t(&tokens, To::FileW, buf, line)
                    elif buf == "tonum" do add_t(&tokens, To::ToNum, buf, line)
                    elif buf == "sys" do add_t(&tokens, To::SysCall, buf, line)
                    elif buf == "fn" do add_t(&tokens, To::Func, buf, line)
                    elif buf == "cfn" do add_t(&tokens, To::CachedFunc, buf, line)
                    elif buf == "loop" do add_t(&tokens, To::Loop, buf, line)
                    elif buf == "BLACK" do add_t(&tokens, To::StringLiteral, "\033[30m", line)
                    elif buf == "RED" do add_t(&tokens, To::StringLiteral, "\033[31m", line)
                    elif buf == "GREEN" do add_t(&tokens, To::StringLiteral, "\033[32m", line)
                    elif buf == "BLUE" do add_t(&tokens, To::StringLiteral, "\033[33m", line)
                    elif buf == "YELLOW" do add_t(&tokens, To::StringLiteral, "\033[34m", line)
                    elif buf == "CYAN" do add_t(&tokens, To::StringLiteral, "\033[35m", line)
                    elif buf == "MAGENTA" do add_t(&tokens, To::StringLiteral, "\033[36m", line)
                    elif buf == "WHITE" do add_t(&tokens, To::StringLiteral, "\033[37m", line)
                    elif buf == "RESET" do add_t(&tokens, To::StringLiteral, "\033[0m", line)
                    elif buf == "BLACKBG" do add_t(&tokens, To::StringLiteral, "\033[40m", line)
                    elif buf == "REDBG" do add_t(&tokens, To::StringLiteral, "\033[41m", line)
                    elif buf == "GREENBG" do add_t(&tokens, To::StringLiteral, "\033[42m", line)
                    elif buf == "BLUEBG" do add_t(&tokens, To::StringLiteral, "\033[43m", line)
                    elif buf == "YELLOWBG" do add_t(&tokens, To::StringLiteral, "\033[44m", line)
                    elif buf == "CYANBG" do add_t(&tokens, To::StringLiteral, "\033[45m", line)
                    elif buf == "MAGENTABG" do add_t(&tokens, To::StringLiteral, "\033[46m", line)
                    elif buf == "WHITEBG" do add_t(&tokens, To::StringLiteral, "\033[47m", line)
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