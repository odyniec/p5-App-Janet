package App::Janet::Tag::Highlight;

use strict;
use warnings;

BEGIN { our @ISA = qw( Template::Liquid::Tag ) }

sub import {
    Template::Liquid::register_tag('highlight', __PACKAGE__);
}

sub new {
    my ($class, $args) = @_;

    return bless {
        end_tag     => 'endhighlight',
        parent      => $args->{'parent'},
        template    => $args->{'template'}
    }, $class;
}

sub render {
    '';
}

1;
