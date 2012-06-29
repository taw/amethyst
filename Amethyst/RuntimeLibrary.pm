package Amethyst::RuntimeLibrary;

use Symbol;

# Integrating Amethyst::World and Amethyst::RuntimeLibrary for now, before
# a sane namespacing is in place
# package Amethyst::World;
package Amethyst::RuntimeLibrary;

sub print
{
    CORE::print(@_);
}

sub puts
{
    local $,="\n";
    local $\="\n";
    CORE::print(@_);
}

sub yield
{
#    print "$X: $Amethyst::BLOCK\n";
    $Amethyst::BLOCK->(@_);
}

package ARRAY;

sub shift
{
    my $self = CORE::shift;
    return CORE::shift @$self;
}

sub unshift
{
    my $self = CORE::shift;
    my $el = CORE::shift;
    CORE::unshift(@$self, $el);
    return $self;
}

sub pop
{
    my $self = CORE::shift;
    return CORE::pop @$self;
}

sub push
{
    my $self = CORE::shift;
    my $el = CORE::shift;
    CORE::push(@$self, $el);
    return $self;
}

sub each
{
    my $self = CORE::shift;
    for(@$self)
    {
        $Amethyst::BLOCK->($_);
    }
    return $self;
}

sub each_with_index
{
    my $self = CORE::shift;
    for(0..$#{$self})
    {
        $Amethyst::BLOCK->($self->{$_}, $_);
    }
    return $self;
}

sub reject
{
    my $self = CORE::shift;
    my @res;
    for(0..$#{$self})
    {
        $Amethyst::BLOCK->($self->{$_}, $_);
    }
    return \@res;
}

sub map
{
    my $self = CORE::shift;
    my @res = CORE::map { $Amethyst::BLOCK->($self->{$_}) } @$self;
    return \@res;
}

# Just for tests
package Amethyst::MAGICK;

sub to_s
{
    "Magick !!!";
}

package Amethyst::SCALAR_METHOD;

sub to_i
{
    my $n=$_[0];
    $n+0
}

sub to_s
{
    my $n=$_[0];
    "$n"
}

package Amethyst::RuntimeLibrary;

# Change this in class X [...] end context

# Perl does not let us know if scalar is string or int in any sane way
sub is_integer { (($_[0])^($_[0])) eq "0" }

sub op_add
{
    my ($a, $b) = @_;
    if(is_integer($a)) { # Integer
        $a + $b
    } else { # String
        $a . $b
    }   
}

sub method
{
    my $obj = shift;
    my $method = shift;
    if(ref $obj) {
        return Symbol::qualify($method, ref$obj);
    } else {
        return ($Amethyst::SCALAR_METHOD::{$method})
    }
}

sub function
{
    my $fname = shift;
#    Symbol::qualify($fname, Amethyst::World);
    Symbol::qualify($fname, Amethyst::RuntimeLibrary);
}

sub call
{
    my $m = shift;
    my $block = shift;
    # If no block was specified, don't clean the $Amethyst::BLOCK
    # This way yield can be just a normal function
    local $Amethyst::BLOCK = $block || $Amethyst::BLOCK;
#    print "Setting yield: $block [ $Amethyst::BLOCK ]\n";
    &$m(@_);
#    print "Restoring yield from $block [ $Amethyst::BLOCK ]\n";
}

1
