package App::Janet::Command;

use strict;
use warnings;

use Moo;

sub process {}

sub process_site {
    my ($self, $site) = @_;

    $site->process();
}

1;
