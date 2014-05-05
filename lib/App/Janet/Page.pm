package App::Janet::Page;

use strict;
use warnings;

use Moo;

sub render {
    my ($self, $layouts, $site_payload) = @_;

    my $payload = $site_payload;

    $self->do_layout($payload, $layouts);
}

1;
