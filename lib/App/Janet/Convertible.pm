package App::Janet::Convertible;

use Moo::Role;
use Template::Liquid;

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
}

sub transform {
    my ($self) = @_;
}

sub render_liquid {
    my ($self, $content, $payload, $info, $path) = @_;

    return Template::Liquid->parse($content)->render(%$payload, %$info);
}

1;
