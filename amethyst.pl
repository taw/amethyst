#!/usr/bin/perl -w

$|=1;

use Data::Dumper;
use Amethyst::Parser;
use Amethyst::Compiler;
use Amethyst::RuntimeLibrary;

my $src;
my $file = shift @ARGV || "strint.am";
{
    open F, "<", $file;
    local $/;
    $src = <F>;
    close F;
};

#print $src;
$ast = Amethyst::Parser::parse($src);
$code = Amethyst::Compiler::rec_compile($ast);

print "Source:\n$src\n\n";
print "Generated code:\n$code\n\n";

print "Output:\n";
eval "package Amethyst::RuntimeLibrary;
$code
";
print "Error: $@\n" if $@;
