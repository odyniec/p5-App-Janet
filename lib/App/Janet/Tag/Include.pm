package App::Janet::Tag::Include;

use strict;
use warnings;

use File::Spec;
use HTML::Escape qw(escape_html);

BEGIN { our @ISA = qw( Template::Liquid::Tag ) }

sub import {
    Template::Liquid::register_tag('include', __PACKAGE__);
}

my $VALID_SYNTAX = qr/([\w-]+)\s*=\s*(?:"([^"\\]*(?:\\.[^"\\]*)*)"|'([^'\\]*(?:\\.[^'\\]*)*)'|([\w\.-]+))/;
my $VARIABLE_SYNTAX = qr/(?<variable>\{\{\s*(?<name>[\w\-\.]+)\s*(\|.*)?\}\})(?<params>.*)/;

my $INCLUDES_DIR = '_includes';

sub new {
    my ($class, $args) = @_;

    (my $markup = $args->{'attrs'}) =~ s/^\s+|\s+$//g;
    my $file;
    my $params;

    if ($markup =~ $VARIABLE_SYNTAX) {
        ($file = $+{'variable'}) =~ s/^\s+|\s+$//g;
        ($params = $+{'params'}) =~ s/^\s+|\s+$//g;
    }
    else {
        ($file, $params) = split(/ /, $markup, 2);
    }

    # TODO: validate_params if $params;

    return bless {
        parent      => $args->{'parent'},
        template    => $args->{'template'},

        file        => $file,
        params      => $params
    }, $class;
}

sub render {
    my ($s) = @_;

    my $site = $s->{'template'}{'context'}->get('registers')->{'site'};
    my $dir = File::Spec->catdir($site->source, $INCLUDES_DIR);

    # TODO: $file = render_variable...

    my $file = $s->{'file'};

    my $data;
    {
        local $/;
        open my $f, '<', File::Spec->catfile($dir, $file);
        $data = <$f>;
        close $f;
    }

    my $partial = Template::Liquid->parse($data);
    $partial->{'context'} = $s->{'template'}{'context'};

    # TODO: This is a result of some reverse-engineering, but I'm not really
    # sure if this is the right way to do this. Might need to take a closer look
    # and figure things out.
    my $output = $partial->{'context'}->stack(sub { $partial->render(
        %{$s->{'template'}{'context'}{'scopes'}[0]}
    ); });

    return $output;
}

1;
