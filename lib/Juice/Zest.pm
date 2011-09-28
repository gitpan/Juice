package Juice::Zest;

=head1 NAME

Juice::Zest - Accomodates Juice

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS
All Juice::Zest does is import use strict, use warnings and 5.010
Taken from Modern::Perl, but I wanted the same feature in Juice's namespace
=cut

use 5.010_000;
use strict;
use warnings;

use mro     ();
use feature ();

sub import {
    warnings->import();
    strict->import();
    feature->import( ':5.10' );
    mro::set_mro( scalar caller(), 'c3' );
}

=head1 AUTHOR
Check out the author of Modern::Perl
=cut
1;
