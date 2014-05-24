package App::Janet::Post;

use strict;
use warnings;

use Hash::Merge::Simple qw(merge);
use Moo;
use POSIX qw(strftime);
use URI::Escape;

use App::Janet::URL;

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

has 'date' => ( is => 'rw' );

has 'slug' => ( is => 'rw' );

sub EXCERPT_ATTRIBUTES_FOR_LIQUID {
    my ($self) = @_;

    # FIXME
    #qw( title url dir date id categories next previous tags path );
    qw( title url date );
}

sub ATTRIBUTES_FOR_LIQUID {
    my ($self) = @_;

    # FIXME
    #( $self->EXCERPT_ATTRIBUTES_FOR_LIQUID, qw( content excerpt ) );
    ( $self->EXCERPT_ATTRIBUTES_FOR_LIQUID, qw( content ) );
}

sub BUILD {
    my ($self) = @_;

    $self->process($self->name);
    $self->read_yaml(undef, $self->name);

    if (exists $self->data->{'date'}) {
        $self->date(Time::Piece->strptime($self->data->{'date'},
            '%Y-%m-%d %H:%M:%S %z'));
    }

    return $self;
}

sub title {
    my ($self) = @_;

    return $self->data->{'title'} || $self->titleized_slug;
}

sub titleized_slug {
    my ($self) = @_;

    return join(' ', map { lcfirst $_ } split('-', $self->slug));
}

sub process {
    my ($self) = @_;

    my ($cats, $date, $slug, $ext) = ($self->name =~ $MATCHER);

    $self->date(Time::Piece->strptime($date, '%Y-%m-%d'));
    $self->slug($slug);
    $self->ext($ext);
}

sub permalink {
    # TODO: Return permalink if defined in post data
}

sub template {
    my ($self) = @_;

    if ($self->site->permalink_style eq 'pretty') {
        return '/:categories/:year/:month/:day/:title/';
    }
    elsif ($self->site->permalink_style eq 'none') {
        return '/:categories/:title.html';
    }
    elsif ($self->site->permalink_style eq 'date') {
        return '/:categories/:year/:month/:day/:title.html';
    }
    elsif ($self->site->permalink_style eq 'ordinal') {
        return '/:categories/:year/:y_day/:title.html';
    }
    else {
        return $self->site->permalink_style;
    }
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
        'year'          => $self->date->strftime("%Y"),
        'month'         => $self->date->strftime("%m"),
        'day'           => $self->date->strftime("%d"),
        'title'         => $self->slug,
        # TODO: i_day
        # TODO: i_month
        'categories'    => '', # FIXME
        'short_month'   => $self->date->strftime("%b"),
        'y_day'         => $self->date->strftime("%j"),
        'output_ext'    => $self->output_ext
    };
}

sub render {
    my ($self, $layouts, $site_payload) = @_;

    # FIXME: This is really really incomplete
    my $payload = merge {
        site => {},
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

sub previous {
    my ($self) = @_;

    for (my $pos = 0; $pos < scalar @{$self->site->posts} - 1; $pos++) {
        if (@{$self->site->posts}[$pos+1] == $self) {
            return @{$self->site->posts}[$pos];
        }
    }

    return;
}

sub next {
    my ($self) = @_;

    for (my $pos = 1; $pos < scalar @{$self->site->posts}; $pos++) {
        if (@{$self->site->posts}[$pos-1] == $self) {
            return @{$self->site->posts}[$pos];
        }
    }

    return;
}

1;
