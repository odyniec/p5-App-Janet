package App::Janet::Configuration;

use strict;
use warnings;

use Cwd;
use File::Spec::Functions;
use Hash::Merge::Simple qw(merge);
use Module::Load;

my %DEFAULTS = (
    source      => getcwd(),
    destination => catdir(getcwd, '_site'),
    layouts     => '_layouts',

    permalink   => 'date',
    baseurl     => ''
);

sub new {
    my ($class, $config) = @_;

    $config = merge { %DEFAULTS }, $config || {};

    return bless $config, $class;
}

sub safe_load_file {
    my ($filename) = @_;

    (my $ext) = ($filename =~ /(\.[^.]+)$/);

    if ($ext eq '.toml') {
        load 'TOML';
        return TOML::from_toml($filename);
    }
    elsif ($ext =~ /\.y(a)?ml/) {
        load 'YAML';
        return YAML::LoadFile($filename);
    }
    else {
        # TODO: Handle error
    }
}

sub source {
    my ($self, $override) = @_;

    return $override->{'source'} || $self->{'source'};
}

sub config_files {
    my ($self, $override) = @_;

    my $config_files = $override->{'config'};

    if (defined($config_files) && $config_files !~ /\S/) {
        $config_files = catfile($self->source(), '_config.yml');
        $config_files = [ $config_files ] if ref($config_files) ne 'ARRAY';
    }

    return $config_files;
}

sub read_config_file {
    my ($file) = @_;

    my $next_config = safe_load_file($file);

    if (ref($next_config) eq 'HASH') {
        return $next_config;
    }
    else {
        # TODO: Handle errors
    }
}

sub read_config_files {
    my ($self, $files) = @_;

    for my $config_file (@$files) {
        my $new_config = read_config_file($config_file);
        my $new_self = merge $self, $new_config;
        @{$self}{keys %$new_self} = values %$new_self;
        # TODO: Handle errors
    }

    # TODO: configuration.fix_common_issues.backwards_compatibilize?
}

1;
