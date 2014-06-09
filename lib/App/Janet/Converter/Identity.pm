package App::Janet::Converter::Identity;

use strict;
use warnings;

use Moo;
use Text::Markdown qw(markdown);

extends 'App::Janet::Converter';

sub matches { 1 }

sub output_ext {
    my ($self, $ext) = @_;

    return $ext;
}

sub convert {
    my ($self, $content) = @_;

    return $content;
}

1;
