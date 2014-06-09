package App::Janet::Draft;

use strict;
use warnings;

use File::Spec;
use Moo;
use Time::Piece;

extends 'App::Janet::Post';

my $MATCHER = qr/^(.*)(\.[^.]+)$/;

sub valid {
    my ($class, $name) = @_;

    return $name =~ $MATCHER;
}

sub containing_dir {
    my ($class, $source, $dir) = @_;

    return File::Spec->catfile($source, $dir, '_drafts');
}

sub relative_path {
    my ($self) = @_;

    return File::Spec->catfile($self->dir, '_drafts', $self->name);
}

sub process {
    my ($self) = @_;

    my ($slug, $ext) = ($self->name =~ $MATCHER);

    $self->date(Time::Piece->strptime(stat(File::Spec->catfile($self->base,
        $self->name)), '%s'));
    $self->slug($slug);
    $self->ext($ext);
}

1;
