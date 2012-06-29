package Amethyst::Compiler;

sub compile_block
{
    my $node = shift;
    my @lambda = @{$node->{LAMBDA}};
    my $body = rec_compile($node->{BODY});
    
    my $lambda = "";
    if(@lambda) {
        $lambda = join(",",map{'$'.$_}@lambda);
        $lambda = "my ($lambda)=\@_; "
    }
    "sub{ $lambda$body }";
}

sub rec_compile
{
    my $node = shift;
    my $ctx = shift || 'default';

    if (ref($node) eq "ARRAY") {
        my @res = ();
        for(@$node)
        {
            my $v = rec_compile($_);
            
#            my @d=sort keys %$_;
#            print "[@d - $v]\n";
            
            push @res, $v;
        }
        if ($ctx eq 'expr_list') {
            return @res;
        } else {
            return "{" . join(";\n", @res) . "}";
        }
    } elsif (ref($node) eq "HASH") {
        if ($node->{OP})
        {
            my $a;
            my $b;
            # Simple evaluation node
            if($node->{OP} eq "*") {
                $a = rec_compile($node->{A});
                $b = rec_compile($node->{B});
                return "($a * $b)";
            } elsif($node->{OP} eq "/") {
                $a = rec_compile($node->{A});
                $b = rec_compile($node->{B});
                return "($a / $b)";
            } elsif($node->{OP} eq "%") {
                $a = rec_compile($node->{A});
                $b = rec_compile($node->{B});
                return "($a / $b)";
            } elsif($node->{OP} eq "+") {
                $a = rec_compile($node->{A});
                $b = rec_compile($node->{B});
                return "op_add($a,$b)";
            } elsif($node->{OP} eq "-") {
                $a = rec_compile($node->{A});
                $b = rec_compile($node->{B});
                return "($a - $b)";
            } elsif($node->{OP} eq "&&") {
                $a = rec_compile($node->{A});
                $b = rec_compile($node->{B});
                return "($a && $b)";
            } elsif($node->{OP} eq "||") {
                $a = rec_compile($node->{A});
                $b = rec_compile($node->{B});
                return "($a || $b)";
            } elsif($node->{OP} eq "&") {
                $a = rec_compile($node->{A});
                $b = rec_compile($node->{B});
                return "($a & $b)";
            } elsif($node->{OP} eq "|") {
                $a = rec_compile($node->{A});
                $b = rec_compile($node->{B});
                return "($a | $b)";
            } elsif($node->{OP} eq "^") {
                $a = rec_compile($node->{A});
                $b = rec_compile($node->{B});
                return "($a ^ $b)";
            } elsif($node->{OP} eq "<<") {
                $a = rec_compile($node->{A});
                $b = rec_compile($node->{B});
                return "($a << $b)";
            } elsif($node->{OP} eq ">>") {
                $a = rec_compile($node->{A});
                $b = rec_compile($node->{B});
                return "($a >> $b)";
            } elsif($node->{OP} eq "!") {
                $a = rec_compile($node->{A});
                return "(! $a)";
            } elsif($node->{OP} eq "-") {
                $a = rec_compile($node->{A});
                return "(- $a)";
            } elsif($node->{OP} eq "~") {
                $a = rec_compile($node->{A});
                return "(~ $a)";
            } elsif($node->{OP} eq "=") {
                # Should we make sure the left side makes sense ?
                # obj.x = y is not supported as for now
                $a = rec_compile($node->{A});
                $b = rec_compile($node->{B});
                return "($a = $b)";
            } elsif($node->{OP} eq "()") {
                # This is totally magical node
                my ($m,@a) = rec_compile($node->{A},'()');
                my $block = shift @{$node->{B}};
                if($block) {
                    $block = compile_block($block);
                } else {
                    $block = "undef";
                }
                my @fa = ($m, $block, @a, map {rec_compile($_)} @{$node->{B}});

                return "call(".join(", ", @fa).")";
            } elsif($node->{OP} eq ".") {
                # This is totally magical node
                $a = rec_compile($node->{A});
                $b = $node->{B};
                my $m = "method($a,'$b')";
                if($ctx eq '()') {
                    return ($m, $a);
                } else {
                    return "call($m, undef, $a)";
                }
            } else {
                print "\tUNKNOWN OP $node->{OP} (", join(" ", sort keys %$node), ")\n";
            }
        } elsif ($node->{ID}) {
            if($ctx eq '()') {
                return ("function('".$node->{ID}."')");
            } else {
                return '$'.$node->{ID};
            }
        } elsif ($node->{NUM}) {
            return $node->{NUM}+0;
        } elsif ($node->{STR}) {
            return '"'.$node->{STR}.'"';
        } elsif ($node->{ARR}) {
            my @values = map{rec_compile($_)} @{$node->{ARR}};
            return "[".join(",",@values)."]";
        } elsif ($node->{DEF}) {
            my $name  = $node->{DEF}{NAME};
            my @fargs = @{$node->{DEF}{FARGS}};
            my $body = rec_compile($node->{BODY});
            my $lambda = "";
            if(@fargs) {
                $lambda = join(",",map{'$'.$_}@fargs);
                $lambda = "my ($lambda)=\@_; "
            }
            return "sub $name { $lambda$body } \n";
        } else {
            print "\tUNKNOWN TYPE (", join(" ", sort keys %$node), ")\n";
        }
    } else {
        print "UNKNOWN node type\n";
    }
}

1
