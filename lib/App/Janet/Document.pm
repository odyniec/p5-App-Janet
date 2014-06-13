package App::Janet::Document;

use strict;
use warnings;

use Moo;

has 'path' => ( is => 'ro' );

has 'site' => ( is => 'ro' );

has 'content' => ( is => 'rw' );

has 'collection' => ( is => 'rw' );

has 'output' => ( is => 'rw' );

sub extname {
    my ($self) = @_;

    return ($self->path =~ /(\.[^.]+)$/)[0];
}

1;
