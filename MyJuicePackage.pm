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
