package Amethyst;

use Amethyst::Parser;
use Amethyst::Compiler;
use Amethyst::RuntimeLibrary;

# Ruby's File#read
sub read_file {
  my $file = shift;
  open F, "<", $file;
  local $/;
  my $rv = <F>;
  close F;
  $rv;
};

1;
