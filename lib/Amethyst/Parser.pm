package Amethyst::Parser;

use Parse::RecDescent;

$::RD_HINT = 1;
# $::RD_TRACE = 1;

sub fold_left
{
    # @{$_[1]} consists of refs to hashes with fields B and XOP
    # $_[0] is anything
    my $base = $_[0];
    my @mod = @{$_[1]};
    for(@mod)
    {
        $base = {
            "OP" => $_->{XOP},
            "A" => $base,
            "B" => $_->{B},
        }
    }
    return $base
}

sub fold_unary
{
    # @{$_[0]} consists of refs to op names
    # $_[1] is anything
    my $base = $_[1];
    my @mod = reverse @{$_[0]};
    for(@mod)
    {
        $base = {
            "OP" => $_,
            "A" => $base,
        }
    }
    return $base
}

sub fold_right
{
    # @{$_[1]} consists of refs to hashes with fields B and XOP
    # $_[0] is anything
    my @r = ($_[0], @{$_[1]});
    
    while (@r >= 2)
    {
        my $R = pop @r;
        my $L = pop @r;
        my $c;
        if (@r) {
            $c = { "XOP" => $L->{XOP},
                   "B"   => {"OP" => $R->{XOP},
                             "A"  => $L->{B},
                             "B"  => $R->{B}}
                 };
        } else {
            $c = {"OP"=>$R->{XOP}, "B"=>$R->{B}, "A"=>$L };
        }
        push @r, $c;
    }
    return $r[0];
}

our @KEYWORDS= qw(and class def else elsif end for if or while);
our %KEYWORD;
$KEYWORD{$_} = 1 for @KEYWORDS;

our $grammar = q{
    str: '"' /[^\\'\\"]+/  '"'                { $item[2] }
    num: /\d+/                                { $item[1] }
    id: /[a-zA-Z_][a-zA-Z0-9_]*[?!]?/        { if ($Amethyst::Parser::KEYWORD{$item[1]}) {undef} else {$item[1]}  }
    array: '[' list ']'                        { $item[2] }

    list: value comma_value(s?)                { [$item[1], @{$item[2]}] }
        |                                { [] }
    comma_value: "," value                { $item[2] }

    o_fif: "if" | "unless" | "while" | "until"
    x_fif: o_fif v_kor                        { {"XOP"=>$item[1], "B"=>$item[2]} }
    v_fif: v_kor x_fif(s?)                { Amethyst::Parser::fold_left($item[1], $item[2]) }

    o_kor: "and"                        { "&&" }
         | "or"                                { "||" }
    x_kor: o_kor v_not                        { {"XOP"=>$item[1], "B"=>$item[2]} }
    v_kor: v_not x_kor(s?)                { Amethyst::Parser::fold_left($item[1], $item[2]) }

    o_not: "not"                        { "!" }
    v_not: o_not(s?) v_def                { Amethyst::Parser::fold_unary($item[1], $item[2]) }

    o_def: "defined"
    v_def: o_def(?) v_asg                { Amethyst::Parser::fold_unary($item[1], $item[2]) }

    o_asg:  "=" | "+=" | "-=" | "*=" | "-=" | "/=" | "*="
         |"<<=" |">>=" | "|=" | "&=" | "^=" | "&&="| "||="
    x_asg: o_asg v_rng                        { {"XOP"=>$item[1], "B"=>$item[2]} }
    v_asg: v_rng x_asg(s?)                { Amethyst::Parser::fold_right($item[1], $item[2]) }
    
    o_rng: ".." | "..."
    x_rng: o_rng v_lor                        { {"XOP"=>$item[1], "B"=>$item[2]} }
    v_rng: v_lor x_rng(?)                { Amethyst::Parser::fold_left($item[1], $item[2]) }
    
    x_lor: "||" v_lan                        { {"XOP"=>$item[1], "B"=>$item[2]} }
    v_lor: v_lan x_lor(s?)                { Amethyst::Parser::fold_left($item[1], $item[2]) }

    x_lan: "&&" v_cmp                        { {"XOP"=>$item[1], "B"=>$item[2]} }
    v_lan: v_cmp x_lan(s?)                { Amethyst::Parser::fold_left($item[1], $item[2]) }

    o_cmp: "==" | "!=" | "<=>"
    x_cmp: o_cmp v_gt                        { {"XOP"=>$item[1], "B"=>$item[2]} }
    v_cmp: v_gt  x_cmp(?)                { Amethyst::Parser::fold_left($item[1], $item[2]) }

    o_gt: ">" | ">=" | "<" | "<="
    x_gt: o_gt v_bor                        { {"XOP"=>$item[1], "B"=>$item[2]} }
    v_gt : v_bor x_gt(s?)                { Amethyst::Parser::fold_left($item[1], $item[2]) }

    o_bor: "|" | "^"
    x_bor: o_bor v_ban                        { {"XOP"=>$item[1], "B"=>$item[2]} }
    v_bor: v_ban x_bor(s?)                { Amethyst::Parser::fold_left($item[1], $item[2]) }

    x_ban: "&" v_shl                        { {"XOP"=>$item[1], "B"=>$item[2]} }
    v_ban: v_shl x_ban(s?)                { Amethyst::Parser::fold_left($item[1], $item[2]) }

    o_shl: "<<" | ">>"
    x_shl: o_shl v_add                        { {"XOP"=>$item[1], "B"=>$item[2]} }
    v_shl: v_add x_shl(s?)                { Amethyst::Parser::fold_left($item[1], $item[2]) }
    
    o_add: "+" | "-"
    x_add: o_add v_mul                        { {"XOP"=>$item[1], "B"=>$item[2]} }
    v_add: v_mul x_add(s?)                { Amethyst::Parser::fold_left($item[1], $item[2]) }
    
    o_mul: "*" | "/" | "%"
    x_mul: o_mul v_umi                        { {"XOP"=>$item[1], "B"=>$item[2]} }
    v_mul: v_umi x_mul(s?)                { Amethyst::Parser::fold_left($item[1], $item[2]) }

    o_umi: "-"
    v_umi: o_umi(s?) v_pow                { Amethyst::Parser::fold_unary($item[1], $item[2]) }

    x_pow: "**" v_upl                        { {"XOP"=>$item[1], "B"=>$item[2]} }
    v_pow: v_upl x_pow(s?)                { Amethyst::Parser::fold_right($item[1], $item[2]) }

    o_upl: "+" | "!" | "~"
    v_upl: o_upl(s?) v_arr                { Amethyst::Parser::fold_unary($item[1], $item[2]) }

    
    fcall: '(' list ')' block(?)        { if(@{$item[4]})
                                            {{"XOP"=>"()", "B"=>[$item[4]->[0], @{$item[2]}]}}
                                          else
                                            {{"XOP"=>"()", "B"=>[undef, @{$item[2]}]}}
                                        }
        |  block                        { {"XOP"=>"()", "B"=>[$item[1]]} }
    
    o_arr: '[' value ']'                { {"XOP"=>"[]", "B"=>$item[2]} }
          | '.' id                        { {"XOP"=>".",  "B"=>$item[2]} }
          | fcall                        { $item[1] }
    v_arr: v_bas o_arr(s?)                { Amethyst::Parser::fold_left($item[1], $item[2]) }

    v_bas: num                                { {"NUM"=>$item[1]} }
         | id                                { {"ID"=>$item[1]} }
         | str                                { {"STR"=>$item[1]} }
         | array                        { {"ARR"=>$item[1]} }
         | '(' value ')'                { $item[2] }
    
    value: v_fif                        { $item[1] }

    elsestmt:
          "end"                                { [] }
        | "else"
          stmt_brk
          stmts
          "end"                                { $item[3] }
        | "elsif" value
          stmt_brk
          stmts
          elsestmt                        { {"IF"=>$item[2], "THEN"=>$item[4], "ELSE"=>$item[5]} }

    ifstmt:
        "if" value
        stmt_brk
        stmts
        elsestmt                        { {"IF"=>$item[2], "THEN"=>$item[4], "ELSE"=>$item[5]} }

    comma_id: "," id                        { $item[2] }
    id_list: id comma_id(s?)                { [$item[1], @{$item[2]}]  }
           |                                 { [] } 
    bargs_opt: '|' id_list  '|'                { $item[2] }
             |                                { [] } 
    block:
        '{' bargs_opt
            stmts_ofs
        '}'                                { {"LAMBDA"=>$item[2], "BODY"=>$item[3]} }

    comma_id: "," id                        { $item[2] }
    id_list: id comma_id(s?)                { [$item[1], @{$item[2]}]  }
           |                                 { [] } 
    fargs_opt: '(' id_list  ')'                { $item[2] }
             |                                { [] } 
    defhead: id fargs_opt                { {"NAME"=>$item[1], "FARGS"=>$item[2]} }

    defstmt:
        "def" defhead
        stmt_brk
        stmts
        "end"                                { {"DEF"=>$item[2], "BODY"=>$item[4]} }

    classhead: id                        { $item[1] }

    classstmt:
        "class" classhead
        stmt_brk
        stmts
        "end"                                { {"CLASS"=>$item[2], "BODY"=>$item[4]} }

    stmt: ifstmt                        { $item[1] }
        | defstmt                        { $item[1] }
        | classstmt                        { $item[1] }
        | value                                { $item[1] }

    stmt_brk: /[\\n;]+/                        { 1 }
    stmt_wb: stmt stmt_brk                { $item[1] }
    stmts: stmt_brk(?)
           stmt_wb(s?)                        { $item[2] }
    stmts_ofs:
           stmt_brk(?)
           stmt_wb(s?)
           stmt(?)                        { [@{$item[2]}, @{$item[3]}] }
    code: stmts                                { $item[1] }
};

$Parse::RecDescent::skip = '[ \t]*';
our $parser = new Parse::RecDescent($grammar) or die "Bad grammar!";

sub parse
{
    my $src = shift;
    return $parser->code($src);
}

1;
