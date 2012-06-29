package Amethyst;

use Amethyst::Parser;
use Amethyst::Compiler;
use Amethyst::RuntimeLibrary;

# Ruby's File#read, Perl6's chomp()
sub read_file {
  my $file = shift;
  open F, "<", $file;
  local $/;
  my $rv = <F>;
  close F;
  $rv;
};

1;
