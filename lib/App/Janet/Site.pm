package App::Janet::Site;

use strict;
use warnings;

use Cwd;
use File::Find;
use File::Spec::Functions qw(catfile rel2abs);
use Moo;

use App::Janet::LayoutReader;
use App::Janet::Page;
use App::Janet::Post;
use App::Janet::StaticFile;

has 'config' => (
    is => 'rw'
);

has 'source' => ( is => 'rw' );
has 'dest' => ( is => 'rw' );

has 'permalink_style' => ( is => 'rw' );
has 'baseurl' => ( is => 'rw' );

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

has 'static_files' => (
    is => 'rw',
    default => sub { [] }
);

sub BUILD {
    my ($self) = @_;

    $self->source(rel2abs($self->config->{'source'}));
    $self->dest(rel2abs($self->config->{'destination'}));
    $self->permalink_style($self->config->{'permalink'});

    $self->setup();

    return $self;
}

sub setup {
    my ($self) = @_;

    require App::Janet::Converter::Markdown;
    require App::Janet::Converter::Identity;

    # FIXME: Do this automatically for all ::Converters?
    $self->converters([
        App::Janet::Converter::Markdown->new,
        App::Janet::Converter::Identity->new
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

    $self->layouts(App::Janet::LayoutReader->new(site => $self)->read);
    $self->read_directories();
}

sub read_directories {
    my ($self, $dir) = @_;

    $dir //= '.';

    my $base = catfile($self->source, $dir);
    
    my $prev_path = Cwd::getcwd;
    chdir($base);

    for (glob("*")) {
        # FIXME: Implement entry filters
        next if /^_|^\./;

        my $f_abs = catfile($base, $_);

        if (-d $f_abs) {
            my $f_rel = catfile($dir, $_);

            $self->read_directories($f_rel)
                unless $self->dest =~ qr( ^ $f_abs /? $ )x;
        }
        elsif (has_yaml_header($f_abs)) {
            my $page = App::Janet::Page->new(site => $self, name => $_);
            push @{$self->pages}, $page;
        }
        else {
            push @{$self->static_files},
                App::Janet::StaticFile->new(site => $self,
                    base => $self->source, dir => $dir, name => $_);
        }
    };

    chdir($prev_path);

    $self->read_posts($dir);
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

    my $base = catfile($self->source, $dir, $subdir);   

    return [] if !-e $base;

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
        $item->write($self->dest);
    }
}

sub site_payload {
    return {};
}

sub each_site_file {
    my ($self) = @_;

    # FIXME: documents
    return [ @{$self->posts}, @{$self->pages}, @{$self->static_files} ];
}

sub has_yaml_header {
    my ($file) = @_;

    # FIXME: Handle errors
    open my $f, '<', $file;
    CORE::read $f, my $buf, 5;
    close $f;

    return $buf =~ /^---\r?\n/;
}

1;
