package App::Janet::Converter::Markdown;

use strict;
use warnings;

use Moo;
use Text::Markdown qw(markdown);

sub matches {
    my ($self, $ext) = @_;

    # FIXME
    return $ext =~ /^\.markdown/;
}

sub output_ext {
    my ($self, $ext) = @_;

    return '.html';
}

sub convert {
    my ($self, $content) = @_;

    return markdown($content);
}

1;
