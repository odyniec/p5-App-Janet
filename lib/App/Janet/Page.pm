package App::Janet::Page;

use strict;
use warnings;

use File::Spec::Functions;
use Hash::Merge::Simple qw(merge);

use Moo;

with 'App::Janet::Convertible';

has 'site' => ( is => 'rw' );
has 'name' => ( is => 'rw' );
has 'ext' => ( is => 'rw' );
has 'data' => ( is => 'rw' );
has 'content' => ( is => 'rw' );
has 'output' => ( is => 'rw' );

sub ATTRIBUTES_FOR_LIQUID {
    my ($self) = @_;

    # FIXME
    #qw( content dir name path url );
    qw( content name url );
}

sub BUILD {
    my ($self) = @_;

    $self->process($self->name);
    $self->read_yaml(undef, $self->name);

    return $self;
}

sub process {
    my ($self) = @_;

    (my $ext = $self->name) =~ /(\.[^.]+)$/;
    $self->ext($ext);
}

sub permalink {
    # TODO: Return permalink if defined in post data
}

sub template {
    my ($self) = @_;

    # FIXME
    return '/:path/';
}

sub url {
    my ($self) = @_;

    $self->{_url} ||= App::Janet::URL->new(
        template => $self->template,
        placeholders => $self->url_placeholders,
        permalink => $self->permalink
    )->to_s;
}

sub url_placeholders {
    my ($self) = @_;

    my @time = localtime;

    return {
        'path'    => '' # FIXME
    };
}

sub render {
    my ($self, $layouts, $site_payload) = @_;

    my $payload = merge {
        page => $self->to_liquid,
    }, $site_payload;

    $self->do_layout($payload, $layouts);
}

sub destination {
    my ($self, $dest) = @_;

    my $path = App::Janet::sanitized_path($dest,
        App::Janet::URL->unescape_path($self->url));
    $path = catfile($path, "index.html") if $path !~ /\.html$/;
    return $path;
}

1;
