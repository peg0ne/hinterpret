struct Stmt
    vector<Expression> expressions
    Stmt => do return
    Stmt vector<Expression> expressions =>
        this->expressions = expressions
    ;
;