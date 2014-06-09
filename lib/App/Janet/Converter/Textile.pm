package App::Janet::Converter::Textile;

use strict;
use warnings;

use Moo;
use Text::Textile;

extends 'App::Janet::Converter';

sub matches {
    my ($self, $ext) = @_;

    # FIXME: Read extensions from configuration
    return $ext =~ /^\.textile/;
}

sub output_ext {
    my ($self, $ext) = @_;

    return '.html';
}

sub convert {
    my ($self, $content) = @_;

    # TODO: Jekyll appears to be doing more stuff here

    return textile($content);
}

1;
