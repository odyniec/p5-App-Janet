package App::Janet::Utils;

use strict;
use warnings;

use Time::Piece;

# A troglodyte approach to parsing a template with embedded Perl code
sub parse_template {
    my ($template) = @_;

    $template =~ s/<%=(.*?)%>/$1/eeg;

    return $template;
}

1;
