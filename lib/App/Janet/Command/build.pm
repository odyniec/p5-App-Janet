package App::Janet::Command::build;

use strict;
use warnings;

use Moo;

use App::Janet::Site;

extends 'App::Janet::Command';

has 'site' => (
    is => 'rw'
);

my $site;

sub process {
    my ($class) = @_;

    $site = App::Janet::Site->new();

    $class->build($site);
}

sub build {
    my ($class, $site) = @_;

    $class->process_site($site);
}

1;
