package App::Janet;

use strict;
use warnings;

# FIXME: Add ABSTRACT

# VERSION

use App::Janet::Configuration;

sub configuration {
    my ($override) = @_;

    my $config = App::Janet::Configuration->new($override);
    $config->read_config_files($config->config_files($override));

    return $config;
}

sub read_config_files {
    my ($self) = @_;

    # TODO: Oh you know what to do
}

1;
