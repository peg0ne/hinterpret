struct Function
    Token identifier 
    vector<Variable> args
    vector<Token> statements
    Function => do return
    Function Token identifier, vector<Variable> args, vector<Token> statements =>
        this->identifier = identifier
        this->args = args
        this->statements = statements
    ;
;