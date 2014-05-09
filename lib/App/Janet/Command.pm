package App::Janet::Command;

use strict;
use warnings;

use Moo;

use App::Janet;
use App::Janet::Configuration;

sub process {}

sub process_site {
    my ($class, $site) = @_;

    $site->process();
}

sub configuration_from_options {
    my ($class, $options) = @_;

    return App::Janet::configuration($options);
}

1;
