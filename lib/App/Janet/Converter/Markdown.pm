package App::Janet::Converter::Markdown;

use strict;
use warnings;

use Text::Markdown qw(markdown);

sub convert {
    my ($self, $content) = @_;

    return markdown($content);
}

1;
