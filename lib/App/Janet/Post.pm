package App::Janet::Post;

use strict;
use warnings;

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

has 'slug' => ( is => 'rw' );

sub BUILD {
    my ($self) = @_;

    $self->process($self->name);
    $self->read_yaml(undef, $self->name);

    return $self;
}

sub process {
    my ($self) = @_;

    my ($cats, $date, $slug, $ext) = ($self->name =~ $MATCHER);

    $self->slug($slug);
    $self->ext($ext);
}

sub permalink {
    # TODO: Return permalink if defined in post data
}

sub template {
    my ($self) = @_;

    # FIXME: Add other templates
    '/:categories/:year/:month/:day/:title/';
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
        'year'          => strftime("%Y", @time),
        'month'         => strftime("%m", @time),
        'day'           => strftime("%d", @time),
        'title'         => $self->slug,
        # TODO: i_day
        # TODO: i_month
        'categories'    => '', # FIXME
        'short_month'   => strftime("%b", @time),
        'y_day'         => strftime("%j", @time),
        'output_ext'    => $self->output_ext
    };
}

sub render {
    my ($self, $layouts, $site_payload) = @_;

    my $payload = $site_payload;

    $self->do_layout($payload, $layouts);
}

sub destination {
    my ($self, $dest) = @_;

    # FIXME: Move elsewhere
    sub sanitized_path {
        my ($base_directory, $questionable_path) = @_;

        use File::Spec::Functions qw(catfile rel2abs);

        my $clean_path = rel2abs($questionable_path, '/');
        $clean_path =~ s{^\w\:/}{/};

        if (index($clean_path, $base_directory) != 0) {
            $clean_path = catfile($base_directory, $clean_path);
        }

        return $clean_path;
    }

    my $path = sanitized_path($dest,
        App::Janet::URL->unescape_path($self->url));
    $path = catfile($path, "index.html") if $path !~ /\.html$/;
    return $path;
}

1;
