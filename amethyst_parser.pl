#!/usr/bin/perl -w -Ilib

use Amethyst;
use Data::Dumper;
$|=1;
$Data::Dumper::Terse = 1;
$Data::Dumper::Indent = 1;

my $file = shift @ARGV;
my $src = Amethyst::read_file($file);
my $ast = Amethyst::Parser::parse($src);

print Dumper($ast);
