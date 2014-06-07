package App::Janet::Convertible;

use strict;
use warnings;

use File::Basename;
use File::Path qw(make_path);
use File::Spec::Functions;
use Hash::Merge::Simple qw(merge);
use Moo::Role;
use Template::Liquid;
use YAML;

use App::Janet::Filters;
use App::Janet::Tag::Gist;
use App::Janet::Tag::Highlight;
use App::Janet::Tag::Include;

sub read_yaml {
    my ($self, $base, $name, $opts) = @_;

    $name = catfile($base, $name) if defined $base;

    {
        undef $/;
        open my $f, '<', $name;
        $self->content(<$f>);
        close $f;
    }

    $self->data({});

    if ($self->content =~ /^(---\s*\n.*?\n)((---|\.\.\.)\s*\n)/s) {
        $self->content($');
        $self->data(YAML::Load($1));
    }
}

sub render_all_layouts {
    my ($self, $layouts, $payload, $info) = @_;

    my $layout = $layouts->{$self->data->{'layout'}};
    my %used = ();
    $used{$layout->name} = 1 if $layout;

    while ($layout) {
        my $payload = merge $payload,
            { 'content' => $self->output, 'page' => $layout->data };

        $self->output(render_liquid($layout->content, $payload, $info,
            catfile($self->site->config->{'layouts'}, $layout->name)));

        if ($layout = $layouts->{$layout->data->{'layout'} || ''}) {
            if (exists $used{$layout->name}) {
                $layout = undef;
            }
            else {
                $used{$layout->name} = 1;
            }
        }
    }
}

sub do_layout {
    my ($self, $payload, $layouts) = @_;

    my $info = {};

    $self->content(render_liquid($self->content, $payload, $info));
    $self->transform;

    $self->output($self->content);

    $self->render_all_layouts($layouts, $payload, $info);
}

sub transform {
    my ($self) = @_;

    $self->content($self->converter->convert($self->content));
}

sub output_ext {
    my ($self) = @_;

    return $self->converter->output_ext($self->ext);
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

sub to_liquid {
    my ($self, $attrs) = @_;

    return {
        map { $_ => $self->$_ || '' }
            defined $attrs ? @$attrs : $self->ATTRIBUTES_FOR_LIQUID
    };
}

sub render_liquid {
    my ($content, $payload, $info, $path) = @_;

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
