fn add_t vector<Token> *tokens, To type, char value, int line => do add_t(tokens, type, string(1, value), line)
fn add_t vector<Token> *tokens, To type, string value, int line =>
    tokens->push_back(Token(type, value, line))
;

fn tokenize Peekable<char> *iter => vector<Token>
    vector<Token> tokens = {}
    let n = Ncurses()
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
            case '<'
            case '>'
            case '-'
            case '/'
            case '*'
            case '+'
                select pair from try_collect_pair(iter, ch, '=')
                    switch ch
                        case '-' dobr add_t(&tokens, To::SubEquals, pair, line)
                        case '+' dobr add_t(&tokens, To::AddEquals, pair, line)
                        case '/' dobr add_t(&tokens, To::DivEquals, pair, line)
                        case '*' dobr add_t(&tokens, To::MulEquals, pair, line)
                        case '<'
                        case '>' dobr add_t(&tokens, To::Operator, pair, line)
                        ;
                    break
                ;
                add_t(&tokens, To::Operator, ch, line)
                break
            case '&'
                select pair from try_collect_pair(iter, ch) dobr add_t(&tokens, To::Operator, ch, line)
                add_t(&tokens, To::Operator, ch, line)
                break
            case '|'
                select pair from try_collect_pair(iter, ch) dobr add_t(&tokens, To::Operator, pair, line)
                add_t(&tokens, To::Indent, ch, line)
                break
            case '!'
                select pair from try_collect_pair(iter, ch, '=') dobr add_t(&tokens, To::Operator, pair, line)
                add_t(&tokens, To::Operator, ch, line)
                break
            case '='
                select pair from try_collect_pair(iter, ch) dobr add_t(&tokens, To::Operator, pair, line)
                add_t(&tokens, To::Equals, ch, line)
                break
            case '\''
            case '"'
                select collected from try_collect_between(iter, ch)
                    add_t(&tokens, To::StringLiteral, collected, line)
                    break
                ;
                pair_panic(&n, $"String not properly closed at Line: {line}")
                break
            case '['
                select pair from try_collect_pair(iter, ch, ']')
                    add_t(&tokens, To::ListLiteral, pair, line)
                    break
                ;
                pair_panic(&n, $"Did you mean to initialize a list? please check that it looks like this '[]' at Line: {line}")
                break
            default
                buf = ""
                if isalpha(ch)
                    while isalpha(ch)
                        buf += string(1, ch)
                        ch = iter->peek().value_or('\n')
                        if isalpha(ch) do iter->next()
                    ;
                    match buf
                    "at" => do add_t(&tokens, To::Operator, buf, line)
                    "len" => do add_t(&tokens, To::Operator, buf, line)
                    "is" => do add_t(&tokens, To::Operator, "==", line)
                    "or" => do add_t(&tokens, To::Operator, "||", line)
                    "and" => do add_t(&tokens, To::Operator, "&&", line)
                    "import" => do add_t(&tokens, To::Import, buf, line)
                    "random" => do add_t(&tokens, To::Random, buf, line)
                    "print" => do add_t(&tokens, To::Print, buf, line)
                    "printnobr" => do add_t(&tokens, To::PrintNoBr, buf, line)
                    "let" => do add_t(&tokens, To::Let, buf, line)
                    "read" => do add_t(&tokens, To::Read, buf, line)
                    "if" => do add_t(&tokens, To::If, buf, line)
                    "exit" => do add_t(&tokens, To::Exit, buf, line)
                    "eval" => do add_t(&tokens, To::Eval, buf, line)
                    "filer" => do add_t(&tokens, To::FileR, buf, line)
                    "filew" => do add_t(&tokens, To::FileW, buf, line)
                    "tonum" => do add_t(&tokens, To::ToNum, buf, line)
                    "sys" => do add_t(&tokens, To::SysCall, buf, line)
                    "fn" => do add_t(&tokens, To::Func, buf, line)
                    "cfn" => do add_t(&tokens, To::CachedFunc, buf, line)
                    "afn" => do add_t(&tokens, To::AsyncFunc, buf, line)
                    "loop" => do add_t(&tokens, To::Loop, buf, line)
                    "for" => do add_t(&tokens, To::For, buf, line)
                    "break" => do add_t(&tokens, To::Break, buf, line)
                    "BLACK" => do add_t(&tokens, To::StringLiteral, "\033[30m", line)
                    "RED" => do add_t(&tokens, To::StringLiteral, "\033[31m", line)
                    "GREEN" => do add_t(&tokens, To::StringLiteral, "\033[32m", line)
                    "BLUE" => do add_t(&tokens, To::StringLiteral, "\033[33m", line)
                    "YELLOW" => do add_t(&tokens, To::StringLiteral, "\033[34m", line)
                    "CYAN" => do add_t(&tokens, To::StringLiteral, "\033[35m", line)
                    "MAGENTA" => do add_t(&tokens, To::StringLiteral, "\033[36m", line)
                    "WHITE" => do add_t(&tokens, To::StringLiteral, "\033[37m", line)
                    "RESET" => do add_t(&tokens, To::StringLiteral, "\033[0m", line)
                    "BLACKBG" => do add_t(&tokens, To::StringLiteral, "\033[40m", line)
                    "REDBG" => do add_t(&tokens, To::StringLiteral, "\033[41m", line)
                    "GREENBG" => do add_t(&tokens, To::StringLiteral, "\033[42m", line)
                    "BLUEBG" => do add_t(&tokens, To::StringLiteral, "\033[43m", line)
                    "YELLOWBG" => do add_t(&tokens, To::StringLiteral, "\033[44m", line)
                    "CYANBG" => do add_t(&tokens, To::StringLiteral, "\033[45m", line)
                    "MAGENTABG" => do add_t(&tokens, To::StringLiteral, "\033[46m", line)
                    "WHITEBG" => do add_t(&tokens, To::StringLiteral, "\033[47m", line)
                    "COLS" => do add_t(&tokens, To::NumberLiteral, $"{COLS}", line)
                    "LINES" => do add_t(&tokens, To::NumberLiteral, $"{LINES}", line)
                    _ => do add_t(&tokens, To::Identifier, buf, line)
                    ;
                ;
                elif isdigit(ch)
                    while isdigit(ch) || ch == '.'
                        buf += string(1, ch)
                        ch = iter->peek().value_or('\n')
                        if isdigit(ch) || ch == '.' do iter->next()
                    ;
                    add_t(&tokens, To::NumberLiteral, buf, line)
                ;
                else do pair_panic(&n, $"Unhandled character found: {string(1,ch)} at Line: {line}")
                break
            ;
        ;
    ;
    n.stop()
    return tokens
;

fn pair_panic Ncurses *n, string message =>
    n->stop()
    panic(message)
;

fn try_collect_pair Peekable<char> *iter, char pair => Option<string> doremi try_collect_pair(iter, pair, pair)
fn try_collect_pair Peekable<char> *iter, char first, char second => Option<string>
    let combo = $"{string(1,first)}{string(1,second)}"
    select p from iter->peek()
        if p == second
            iter->next()
            return Some(combo)
        ;
    ;
    return None<string>()
;

fn try_collect_between Peekable<char> *iter, char end => Option<string>
    let collected = ""
    loop
        select ch from iter->next()
            if ch == '\\'
                if iter->peek().value_or(' ') == 'n'
                    collected += string(1, '\n')
                    iter->next()
                    continue
                ;
            ;
            if ch == end do break
            else doco collected += string(1, ch)
        ;
        return None<string>()
    ;
    return Some(collected)
;