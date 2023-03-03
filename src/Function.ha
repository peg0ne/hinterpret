struct Function
    Token identifier 
    vector<Variable> args
    vector<Stmt> statements
    Function => do return
    Function Token identifier, vector<Variable> args, vector<Stmt> statements =>
        this->identifier = identifier
        this->args = args
        this->statements = statements
    ;
;