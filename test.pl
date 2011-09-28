#!/usr/bin/env perl

use Juice::Zest;
use Juice;
use FindBin;
use lib "$FindBin::Bin";
use MyJuicePackage; # load our newly created package

say "x = " . _s('x');
_x 'add_to_x';
say "x = " . _s('x');
