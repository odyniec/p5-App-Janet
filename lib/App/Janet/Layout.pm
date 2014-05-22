package App::Janet::Layout;

use strict;
use warnings;

use Moo;

with 'App::Janet::Convertible';

has 'site' => ( is => 'ro' );
has 'name' => ( is => 'ro' );
has 'ext' => ( is => 'rw' );
has 'data' => ( is => 'rw' );
has 'content' => ( is => 'rw' );

sub BUILD {
    my ($self, $args) = @_;

    my $base = delete $args->{'base'};

    $self->process($self->name);
    $self->read_yaml($base, $self->name);

    return $self;
}

sub process {
    my ($self) = @_;

    (my $ext) = ($self->name =~ /(\.[^.]+)$/);
    
    $self->ext($ext);
}

1;
