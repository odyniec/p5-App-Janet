package App::Janet::Filters;

use POSIX qw(strftime);
use Template::Liquid;
use Time::Piece;

sub date_to_string {
    my ($date) = @_;

    $date = Time::Piece->strptime($date, '%Y-%m-%d')
        if ref($date) ne 'Time::Piece';

    return $date->strftime("%d %b %Y");
}

sub date_to_long_string {
    my ($date) = @_;

    $date = Time::Piece->strptime($date, '%Y-%m-%d')
        if ref($date) ne 'Time::Piece';

    return $date->strftime("%d %B %Y");
}

sub xml_escape {
    # TODO
}

Template::Liquid::register_filter(qw(date_to_string date_to_long_string
    xml_escape));

1;
