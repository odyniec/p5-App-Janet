package App::Janet::Command::build;

use strict;
use warnings;

use Getopt::Long qw(GetOptionsFromArray);
use Moo;

use App::Janet::Site;

extends 'App::Janet::Command';

has 'site' => (
    is => 'rw'
);

my $site;

sub process {
    my ($class, $options, @args) = @_;
    
    GetOptionsFromArray(\@args,
    );

    $site = App::Janet::Site->new($options);

    $class->build($site, $options);
}

sub build {
    my ($class, $site, $options) = @_;

    $class->process_site($site);
}

1;
