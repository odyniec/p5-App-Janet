package App::Janet::Plugin;

use strict;
use warnings;

use Moo;

has 'config' => ( is => 'rw', default => sub { {} } );

1;
