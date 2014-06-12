package App::Janet::Collection;

use strict;
use warnings;

use Moo;

use App::Janet;

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

sub docs {
    $self->{'docs'} ||= [];
}

sub read {

}

sub entries {

}

sub filtered_entries {
    my ($self) = @_;

    return [] unless $self->exists;

    # TODO: Find documents
}

sub relative_directory {
    my ($self) = @_;

    return '_' . $self->label;
}

sub directory {
    my ($self) = @_;

    return App::Janet::sanitized_path($self->site->source,
        $self->relative_directory);
}

sub exists {
    my ($self) = @_;

    return (-d $self->directory && !(-l $self->directory && $self->site->safe));
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
