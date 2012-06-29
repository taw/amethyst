#!/usr/bin/perl -w -Ilib

use Amethyst;
use Data::Dump qw(dump);
$|=1;

my $file = shift @ARGV;
my $src = Amethyst::read_file($file);
my $ast = Amethyst::Parser::parse($src);

dump($ast);
