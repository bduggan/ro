use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
  VERSION   => '0.01',
  PREREQ_PM => {
    'Mojolicious' => '6.56',
    'Time::Hires' => 0,
    'List::Util' => 0,
    },
  test      => {TESTS => 't/*.t'}
);
