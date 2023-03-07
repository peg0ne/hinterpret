struct Function
    Token identifier 
    vector<Variable> args
    vector<Token> statements
    bool allow_cache = false
    Dictionary<string,Variable> cache = Dictionary<string,Variable>()
    Function => do return
    Function Token identifier, vector<Variable> args, vector<Token> statements, bool allow_cache =>
        this->identifier = identifier
        this->args = args
        this->statements = statements
        this->allow_cache = allow_cache
    ;
;