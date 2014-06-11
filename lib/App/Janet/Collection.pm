package App::Janet::Collection;

use strict;
use warnings;

use Moo;

has 'site' => ( is => 'ro' );
has 'label' => ( is => 'ro' );
has 'metadata' => ( is => 'ro' );

sub BUILDARGS {
    my ($class, $site, $label) = @_;

    return {
        'site'  => $site,
        'label' => sanitize_label($label),
    };
}

sub BUILD {
    my ($self) = @_;

    $self->metadata($self->extract_metadata);
}

sub extract_metadata {
    my ($self) = @_;

    if (ref($self->site->config->{'collections'}) eq 'HASH') {
        return $self->site->config->{'collections'}->{$self->label} || {};
    }
    else {
        return {};
    }
}

sub sanitize_label {
    my ($label) = @_;

    $label =~ s/[^a-z0-9_\-]//ig;

    return $label;
}

1;
