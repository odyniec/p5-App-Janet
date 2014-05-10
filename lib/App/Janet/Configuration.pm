package App::Janet::Configuration;

use Cwd;
use File::Spec::Functions;
use Hash::Merge::Simple qw(merge);

my %DEFAULTS = (
    source      => getcwd(),
    destination => catdir(getcwd, '_site'),

    permalink   => 'date'
);

sub new {
    my ($class, $config) = @_;

    $config = merge { %DEFAULTS }, $config || {};

    return bless $config, $class;
}

sub source {
    my ($self, $override) = @_;

    return $override->{'source'} || $self->{'source'};
}

sub config_files {
    my ($self, $override) = @_;

    my $config_files = $override->{'config'};

    if ($config_files !~ /\S/) {
        $config_files = catfile($self->source(), '_config.yml');
    }

    $config_files = [ $config_files ] if ref($config_files) ne 'ARRAY';

    return $config_files;
}

sub read_config_files {
    my ($self) = @_;

    # TODO: Oh you know what to do
}

1;
