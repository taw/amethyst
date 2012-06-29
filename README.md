amethyst
========

Amethyst provides Ruby-like syntax for Perl.
The aim of the project is to let programmer use most CPAN modules,
but with clean, functional and object-oriented Ruby way.

How well it works?
==================

The code is meant as proof of concept, if you use it in production
you're a crazy person (also you're awesome!).

There are many problems with this approach, including:
* Perl does not differentiates between String and Integer.
  We must hack a lot, as we don't want a MagickStringAndIntegerAtTheSameTime class
  Maybe we should embed every scalar in Amethyst::String / Amethyst::Integer classes ?
* List and scalar context - ouch.
  As a rule, all variables in Amethyst are scalars,
  so Array variables are merely references to Perl Arrays.
  I think using *x here and there should provide most of the bridging needed.
* Namespacing is completely different in Perl and Ruby.
  Some technically-sound middle-ground must be found.
* Implementing Lexical scoping will be difficult,
  especially with this ad-hoc text-only approach to code generation.
* Exceptions ... ouch


usage
=====
To test, run:
./amethyst.pl examples/strint.am

For parser or compiler steps only:
./amethyst_parser.pl examples/strint.am
./amethyst_compiler.pl examples/strint.am

The examples/hello.am file only tests the parser, the code is too difficult for a compiler.

It's a one-liner quality code. There's no error detection/correction.
On parse errors, the parser ignores the rest of the code, and doesn't even say something went wrong.
It may randomly blow at you.

License
=======

Do whatever you want as long as you preserve attribution.
(for longer legalese take any MIT/BSD license)

Contact
=======

If you have any questions, contact me: Tomasz Wegrzanowski <Tomasz.Wegrzanowski@gmail.com>
