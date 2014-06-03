package App::Janet::Draft;

use strict;
use warnings;

use Moo;

extends 'App::Janet::Post';

my $MATCHER = qr/^(.*)(\.[^.]+)$/;

sub process {
    my ($self) = @_;

    my ($slug, $ext) = ($self->name =~ $MATCHER);

    $self->slug($slug);
    $self->ext($ext);
}

1;
