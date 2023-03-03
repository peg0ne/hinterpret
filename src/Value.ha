struct Value
    Option<double> value_d
    Option<string> value_s
    Option<bool> value_b
    Value => do return
    Value double value => do value_d = Some(value)
    Value string value => do value_s = Some(value)
    Value bool value => do value_b = Some(value)
    fn get_type => To
        if value_d.is_some() doremi To::NumberLiteral
        if value_s.is_some() doremi To::StringLiteral
        if value_b.is_some() doremi To::BooleanLiteral
        else doremi To::None
    ;
;