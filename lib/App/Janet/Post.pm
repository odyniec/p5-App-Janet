package App::Janet::Post;

use strict;
use warnings;

use Moo;

with 'App::Janet::Convertible';

my $MATCHER = qr/^(.+\/)*(\d+-\d+-\d+)-(.*)(\.[^.]+)$/;

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

has 'output' => (
    is => 'rw'
);

has 'ext' => (
    is => 'rw'
);

sub BUILD {
    my ($self) = @_;

    $self->process($self->name);
    $self->read_yaml(undef, $self->name);

    return $self;
}

sub process {
    my ($self) = @_;

    my ($cats, $date, $slug, $ext) = ($self->name =~ $MATCHER);

    $self->ext($ext);
}

sub render {
    my ($self, $layouts, $site_payload) = @_;

    my $payload = $site_payload;

    $self->do_layout($payload, $layouts);
}

1;
