#!/usr/bin/perl -w -Ilib

use Amethyst;
$|=1;

my $file = shift @ARGV;
my $src = Amethyst::read_file($file);
my $ast = Amethyst::Parser::parse($src);
my $code = Amethyst::Compiler::rec_compile($ast);

eval "package Amethyst::RuntimeLibrary;
$code
";
print "Error: $@\n" if $@;
