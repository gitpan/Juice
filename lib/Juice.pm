package Juice;

use Juice::Zest; # Zest imports use strict and warnings, as well as 5.010

use base 'Exporter';
our @EXPORT = qw/_x is_func def func has _s loop squeeze/;
our $s = {};            # variables are set here
our $function = {};     # functions here

=head1 NAME

Juice - Live on the edge; share methods and variables between packages easily.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.03';


=head1 SYNOPSIS

Juice provides a way to share methods and variables between packages. No exporting, 
no inheritance, no OO programming. Probably not the best practice, but if you want 
a quick fix and don't care about the quality of your code, then Juice it!

    ## MyJuicePackage.pm
    package MyJuicePackage;

    use Juice::Zest; # imports use strict/warnings and 5.010;
    use Juice;

    # set a variable called 'x' that can be called ANYWHERE
    # using a special Juice function
    has [{ x => 5 }];

    def 'add_to_x' => sub {
        has [{ x => _s('x')+1 }];
        say "Added 1 to x";
    };
    1;

    ## test.pl
    use Juice::Zest;
    use Juice;
    
    use MyJuicePackage; # load our newly created package
    
    say "x = " . _s('x');
    
    _x 'add_to_x';
    
    say "x = " . _s('x');

Running the above returns:
    x = 5
    Added 1 to x
    x = 6
=cut

=head2 squeeze
Adds a 'new' constructor to your package on the fly. If you pass arguments to it in the form 
of a hash, then it will bless them for you automatically.
    
    package MyApp;
    
    use Juice;

    squeeze({ name => 'foo' });

    sub get_name {
        my $self = shift;
        
        return $self->{name};
    }
    1;

    # test.pl
    use MyApp;
    
    my $j = MyApp->new;
    print "Hello, $j->{name}\n"; # returns 'Hello, foo'
=cut

sub squeeze {
    my $args = shift;
    my $pkg = caller();
    my %inself = %{$args};
    eval qq{
        package $pkg;
        sub new {
            my \$self = {%inself};
            bless \$self, $pkg;
            return \$self;
        }
    };
}
    
=head2 func
Creates an anonymous subroutine in $function->{func_name}
This allows you to run the function from anywhere using _x(func_name)

    func 'mysub' => sub {
        say "Hello, World!";
    };
    
    _x 'mysub';

    # outputs:
    # Hello, World!

The above example can be called from the current package, or any other 
packages using it.
=cut

sub func {
    use vars qw/$function/;
    my ($func, $value) = @_;

    $function->{$func} = $value;
}

=head2 def
A shortcut for func (by 1 letter!). Originally I used func as this method, 
but decided I liked def better. You can use either one - they do the same thing.
=cut

sub def {
    use vars qw/$function/;
    my ($func, $value) = @_;

    $function->{$func} = $value;
}

=head2 _x
Run a Juice function with/without arguments

    _x 'mysub'; # without arguments
    _x 'mysub', 'hello', [qw/1 2 3 4 5/]; # with arguments
=cut

sub _x {
    my ($func, @args) = @_;

    $function->{$func}->(@args);
}

=head2 is_juiced
Returns 1 or 0 whether a function or variable has been 'juiced'. This means 
is it a def, func or has.

    has [{ x => 5 }];
    my $y = 7;

    if (is_juiced('x')) { say "Hooray!"; }
    if (! is_juiced('y')) { say "Boo!"; }

    # output:
    # Hooray!
    # Boo!
=cut

sub is_juiced {
    my $func = shift;

    if ((! exists $function->{$func} && ! exists $s->{$func})) { return 0; }
    return 1;
}

=head2 has
No. This is nothing like Moose. Juice's has acts as a variable that can 
hold any given type and be accessed from absolutely anywhere; packages, subroutines, loops.
You can set multiple variables in one go, or a single one. You may also give it a type, so if the ref 
does not match it will throw out errors.
All has definitions need to be referenced by _s

    has [{ name => 'foo' }]; # a simple example
    has [{ name => 'foo' }, { food => 'pizza' }]; # setting two variables in one instance

    say _s('name'); # returns 'foo'

    # you can also create anonymous subs out of them
    has [{
        mysub => sub {
            my $name = shift;
            say "Hello, $name!";
        }
    }];
    
    _s('mysub')->('World'); # prints 'Hello, World!'
=cut

sub has {
    use vars qw/$s/;

    my $sargs = shift;
    for(my $i = 0; $i < @$sargs; $i++) {
        my $v = $sargs->[$i];
        for(keys %$v) {
            if ($_ eq 'type') {
                if (uc $v->{$_} ne ref $v->{$_}) {
                    die "Reference type for $v->{key} is $v->{type}, but a " . (ref $v->{val}) . " was received instead";
                }
            }
            else {
                $s->{$_} = $v->{$_};
                return $s->{$_}||0 unless @$sargs > 1;
            }
        }
    }
}

=head2 loop
Just another way to perform a loop. Nothing special, really.
It allows you to use callbacks for the data, or an inline sub

    loop [qw/1 2 3/], sub {
        say shift;
    };
    
    # output:
    # 1
    # 2
    # 3

    # or via a callback
    
    has [{
        cb => sub {
            my $animal = shift;
            say "On the farm there is a $animal";
        }
    }];

    loop [qw/Donkey Cow Horse Camel/], _s('cb');
=cut

sub loop {
    my ($a,$c) = @_;

    foreach (@$a) { $c->($_); }
}

=head _s
Returns a 'has' variable, if any.

    has [{ foo => 'bar' }];
    say _s 'foo'; # return 'foo'
=cut

sub _s {
    use vars qw/$s/;
    my ($key, $val) = @_;

    if (!$val) {
        return $s->{$key};
    }
}

=head1 AUTHOR

Brad Haywood, C<< <brad at geeksware.net> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-juice at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Juice>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Juice


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Juice>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Juice>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Juice>

=item * Search CPAN

L<http://search.cpan.org/dist/Juice/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2011 Brad Haywood.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of Juice
