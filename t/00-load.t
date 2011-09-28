#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Juice' ) || print "Bail out!\n";
}

diag( "Testing Juice $Juice::VERSION, Perl $], $^X" );
