package App::Janet::StaticFile;

use strict;
use warnings;

use File::Basename;
use File::Copy;
use File::Path qw(make_path);
use File::Spec::Functions qw(catfile);
use File::stat;
use Moo;

has 'site' => ( is => 'rw' );

has 'base' => ( is => 'rw' );

has 'dir' => ( is => 'rw' );

has 'name' => ( is => 'rw' );

my %mtimes = ();

sub path {
    my ($self) = @_;

    return catfile($self->base, $self->dir, $self->name);
}

sub destination {
    my ($self, $dest) = @_;

    return catfile($dest, $self->dir, $self->name);
}

sub mtime {
    my ($self) = @_;

    return stat($self->path)->mtime;
}

sub modified {
    my ($self) = @_;

    return ($mtimes{$self->path} || 0) != $self->mtime;
}

sub write {
    my ($self, $dest) = @_;

    my $dest_path = $self->destination($dest);

    return 0 if -e $dest_path && !$self->modified;
    $mtimes{$self->path} = $self->mtime;

    make_path(dirname($dest_path));
    copy($self->path, $dest_path);

    return 1;
}

1;
