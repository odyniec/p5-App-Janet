package App::Janet::Convertible;

use File::Basename;
use File::Path qw(make_path);
use Moo::Role;
use Template::Liquid;

use App::Janet::Tag::Highlight;

sub read_yaml {
    my ($self, $base, $name, $opts) = @_;

    {
        undef $/;
        open my $f, '<', $name;
        $self->content(<$f>);
        close $f;
    }

    $self->data({});

    if ($self->content =~ /^(---\s*\n.*?\n)((---|\.\.\.)\s*\n)/s) {
        $self->content($');
        # $self->data() # FIXME: Load YAML from $1
    }
}

sub do_layout {
    my ($self, $payload, $layouts) = @_;

    my $info = {};

    $self->content($self->render_liquid($self->content, $payload, $info));
    $self->transform;

    $self->output($self->content);
}

sub transform {
    my ($self) = @_;

    $self->content($self->converter->convert($self->content));
}

sub converter {
    my ($self) = @_;

    $self->{_converter} or do {
        for my $converter (@{$self->site->converters}) {
            if ($converter->matches($self->ext)) {
                return $self->{_converter} = $converter;
            }
        }
    };
}

sub render_liquid {
    my ($self, $content, $payload, $info, $path) = @_;

    return Template::Liquid->parse($content)->render(%$payload, %$info);
}

sub write {
    my ($self, $dest) = @_;

    my $path = $self->destination($dest);

    make_path(dirname($path));

    open my $f, '>', $path;
    print $f $self->output;
    close $f;
}

1;
