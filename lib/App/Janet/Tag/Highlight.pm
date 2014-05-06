package App::Janet::Tag::Highlight;

use strict;
use warnings;

use HTML::Escape qw(escape_html);

BEGIN { our @ISA = qw( Template::Liquid::Tag ) }

sub import {
    Template::Liquid::register_tag('highlight', __PACKAGE__);
}

my $SYNTAX = qr/^([a-zA-Z0-9.+#-]+)((\s+\w+(=\w+)?)*)$/;

sub new {
    my ($class, $args) = @_;

    my $lang;
    my $options = {};

    if ($args->{attrs} =~ $SYNTAX) {
        $lang = lc $1;

        if (defined($2) && $2 ne '') {
            (my $opts = $2) =~ s/^\s+|\s+$//g;
            for my $opt (split(/\s+/, $opts)) {
                my ($key, $value) = split('=', $opt);
                $options->{$key} = $value;
            }
        }
    }
    else {
        # FIXME: Syntax error
    }

    return bless {
        end_tag     => 'endhighlight',
        parent      => $args->{'parent'},
        template    => $args->{'template'},

        lang        => $lang,
        options     => $options,
    }, $class;
}

sub render {
    my ($s) = @_;

    my $output = render_codehighlighter($s->{'nodelist'}[0]);

    $output = add_code_tag($output, $s->{'lang'});

    # FIXME: prefix/suffix
    return $output;
}

sub render_codehighlighter {
    my ($code) = @_;

    $code =~ s/^\s+|\s+$//g;

    return "<div class=\"highlight\"><pre>" . escape_html($code) .
        "</pre></div>";
}

sub add_code_tag {
    my ($code, $lang) = @_;

    (my $lang_classes = $lang) =~ y/+/-/;

    $code =~ s!<pre>\n*!<pre><code class="$lang_classes">!;
    $code =~ s!\n*</pre>!</code></pre>!;
    $code =~ s/^\s+|\s+$//g;

    return $code;
}

1;
