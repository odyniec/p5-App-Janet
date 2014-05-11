package App::Janet::LayoutReader;

use Cwd;
use File::Find;
use File::Spec;
use Moo;

use App::Janet;
use App::Janet::Layout;

has 'site' => ( is => 'ro' );
has 'layouts' => ( is => 'ro', default => sub { {} } );

sub read {
    my ($self) = @_;

    for my $f (@{$self->layout_entries}) {
        $self->layouts->{layout_name($f)} = App::Janet::Layout->new(
            site => $self->site,
            base => $self->layout_directory,
            name => $f
        );
    }

    return $self->layouts;
}

sub layout_directory {
    my ($self) = @_;

    return $self->{_layout_directory} ||= ($self->layout_directory_in_cwd ||
        $self->layout_directory_inside_source);
}

sub layout_entries {
    my ($self) = @_;

    my @entries = ();

    # TODO: Reimplement this using entry filters (like Jekyll does)
    my $prev_path = Cwd::getcwd;
    chdir($self->layout_directory);

    find({
        wanted => sub {
            push @entries, File::Spec->abs2rel($File::Find::name) if !-d;
        },
        no_chdir => 1
    }, '.');

    chdir($prev_path);

    return \@entries;
}

sub layout_name {
    my ($file) = @_;

    $file =~ s/\.[^.]*$//;

    return $file;
}

sub layout_directory_inside_source {
    my ($self) = @_;

    return App::Janet::sanitized_path($self->site->source,
        $self->site->config->{'layouts'});
}

sub layout_directory_in_cwd {
    my ($self) = @_;

    my $dir = App::Janet::sanitized_path(Cwd::getcwd,
        $self->site->config->{'layouts'});

    return $dir if -d $dir;
}

1;
