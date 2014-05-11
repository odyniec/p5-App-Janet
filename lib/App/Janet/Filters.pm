package App::Janet::Filters;

use POSIX qw(strftime);
use Template::Liquid;
use Time::Piece;

sub date_to_string {
    return Time::Piece->strptime($_[0], '%Y-%m-%d')->strftime("%d %b %Y");
}

Template::Liquid::register_filter(qw(date_to_string));

1;
