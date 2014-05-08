package App::Janet::URL;

use URI::Escape;

sub new {
    my ($class, %options) = @_;

    return bless {
        _template => $options{template},
        _placeholders => $options{placeholders} || {},
        _permalink => $options{permalink}
    }, $class;
}

sub to_s {
    my ($self) = @_;

    return sanitize_url($self->{_permalink} || $self->generate_url);
}

sub generate_url {
    my ($self) = @_;

    my $result = $self->{_template};

    while (($name, $value) = each %{$self->{_placeholders}}) {
        $value = __PACKAGE__->escape_path($value);
        $result =~ s/:$name/$value/g;
    }

    return $result;
}

sub sanitize_url {
    my ($in_url) = @_;

    (my $url = $in_url) =~ s{//}{/}g;
    $url = join('/', grep { !/^\.+$/ } split('/', $url));
    $url .= '/' if $in_url =~ m{/$};
    $url =~ s/^([^\/])/\/$1/;

    return $url;
}

sub escape_path {
    my ($class, $path) = @_;

    return uri_escape($path, '^a-zA-Z\d\-._~!$&\'()*+,;=:#@/');
}

sub unescape_path {
    my ($class, $path) = @_;

    return uri_unescape($path);
}

1;
