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

sub sanitized_path {
    my ($base_directory, $questionable_path) = @_;

    use File::Spec::Functions qw(catfile rel2abs);

    my $clean_path = rel2abs($questionable_path, '/');
    $clean_path =~ s{^\w\:/}{/};

    if (index($clean_path, $base_directory) != 0) {
        $clean_path = catfile($base_directory, $clean_path);
    }

    return $clean_path;
}

1;
