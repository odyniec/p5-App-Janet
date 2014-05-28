package App::Janet::Tag::Gist;

use strict;
use warnings;

BEGIN { our @ISA = qw( Template::Liquid::Tag ) }

sub import {
    Template::Liquid::register_tag('gist', __PACKAGE__);
}

my $SYNTAX = qr/^([a-zA-Z0-9.+#-]+)((\s+\w+(=\w+)?)*)$/;

sub new {   
    my ($class, $args) = @_;

    my $gist_id;
    my $filename;

    if ($args->{attrs} =~ m{/}) {
        ($gist_id, $filename) =
            ($args->{attrs} =~ /^([a-zA-Z0-9\/\-_]+) ?(\S*)$/);
    }
    else {
        ($gist_id, $filename) = ($args->{attrs} =~ /^(\d+) ?(\S*)$/);
    }

    return bless {
        parent      => $args->{'parent'},
        template    => $args->{'template'},

        gist_id     => $gist_id,
        filename    => $filename,
    }, $class;
}

sub render {
    my ($s) = @_;

    my $output;

    if (defined($s->{'filename'}) && $s->{'filename'} =~ m{.}) {
        $output = "<script src=\"https://gist.github.com/" . $s->{'gist_id'} .
            ".js?file=" . $s->{'filename'} . "\"> </script>";
    }
    else {
        $output = "<script src=\"https://gist.github.com/" . $s->{'gist_id'} .
            ".js\"> </script>";
    }

    return $output;
}

1;
