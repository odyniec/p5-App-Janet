package App::Janet::Site;

use strict;
use warnings;

use File::Find;
use File::Spec::Functions qw(catfile rel2abs);
use Moo;

use App::Janet::Post;

has 'config' => (
    is => 'rw'
);

has 'source' => ( is => 'rw' );
has 'dest' => ( is => 'rw' );

has 'converters' => (
    is => 'rw',
    default => sub { [] }
);

has 'generators' => (
    is => 'rw',
    default => sub { [] }
);

has 'layouts' => (
    is => 'rw',
    default => sub { {} }
);

has 'posts' => (
    is => 'rw',
    default => sub { [] }
);

has 'pages' => (
    is => 'rw',
    default => sub { [] }
);

sub BUILD {
    my ($self, $config) = @_;

    $self->config($config);

    $self->source(rel2abs($config->{'source'}));
    $self->dest(rel2abs($config->{'destination'}));

    $self->setup();

    return $self;
}

sub setup {
    my ($self) = @_;

    require App::Janet::Converter::Markdown;

    # FIXME: Do this automatically for all ::Converters?
    $self->converters([
        App::Janet::Converter::Markdown->new
    ]);    
}

sub process {
    my ($self) = @_;

    $self->reset();
    $self->read();
    $self->generate();
    $self->render();
    $self->cleanup();
    $self->write();
}

sub reset {
    my ($self) = @_;
}

sub read {
    my ($self) = @_;

    $self->read_directories();
}

sub read_directories {
    my ($self, $dir) = @_;

    $dir //= '';

    $self->read_posts($dir)
}

sub read_posts {
    my ($self, $dir) = @_;

    $self->posts($self->read_content($dir, '_posts', 'Post'));
}

sub read_content {
    my ($self, $dir, $magic_dir, $class) = @_;

    return [
        map { ('App::Janet::' . $class)->new(site => $self, name => $_) }
            @{$self->get_entries($dir, $magic_dir)}
    ];
}

sub get_entries {
    my ($self, $dir, $subdir) = @_;

    # FIXME: '.' -> $source
    my $base = catfile('.', $dir, $subdir);
    my @entries = ();

    find({
        wanted => sub {
            # All non-directories are welcome
            push @entries, $File::Find::name if !-d;
        },
        no_chdir => 1
    }, $base);

    return \@entries;
}

sub generate {
    my ($self) = @_;

    for my $generator (@{$self->generators}) {
        $generator->generate($self);
    }
}

sub render {
    my ($self) = @_;

    for my $page_or_post (@{$self->posts}, @{$self->pages}) {
        $page_or_post->render($self->layouts, $self->site_payload);
    }
}

sub cleanup {
    my ($self) = @_;
}

sub write {
    my ($self) = @_;

    for my $item (@{$self->each_site_file}) {
        $item->write(); # FIXME: dest
    }
}

sub site_payload {
    return {};
}

sub each_site_file {
    my ($self) = @_;

    # FIXME: static_files, documents
    return [ @{$self->posts}, @{$self->pages} ];
}

1;
