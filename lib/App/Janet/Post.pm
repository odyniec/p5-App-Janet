package App::Janet::Post;

use strict;
use warnings;

use Moo;

with 'App::Janet::Convertible';

has 'name' => (
    is => 'ro'
);

has 'site' => (
    is => 'rw'
);

has 'data' => (
    is => 'rw'
);

has 'content' => (
    is => 'rw'
);

sub BUILD {
    my ($self) = @_;

    $self->read_yaml(undef, $self->name);

    return $self;
}

sub render {
    my ($self, $layouts, $site_payload) = @_;

    my $payload = $site_payload;

    $self->do_layout($payload, $layouts);
}

1;
