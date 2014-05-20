package App::Janet::Command::new;

use strict;
use warnings;

use Cwd;
use File::Copy::Recursive qw(dircopy);
use File::Path qw(make_path);
use File::Share;
use File::Spec;
use Getopt::Long qw(GetOptionsFromArray);
use Moo;
use Time::Piece;

use App::Janet::Utils;

my %options = (
    force => 0,
    blank => 0,
);

my $scaffold_path = File::Spec->catfile('_posts',
    '0000-00-00-welcome-to-jekyll.markdown.perl');

sub process {
    my ($class, $options, @args) = @_;

    GetOptionsFromArray(\@args,
        'force' => \$options{force},
        'blank' => \$options{blank}
    );
    
    my $path = shift @args;

    my $new_blog_path = File::Spec->rel2abs($path);

    make_path($new_blog_path);
    
    if ($options{'blank'}) {
        create_blank_site($new_blog_path);
    }
    else {
        create_sample_files($new_blog_path);

        open my $f, '>', File::Spec->catfile($new_blog_path,
            initialized_post_name());
        print $f scaffold_post_content();
        close $f;
    }
}

sub create_blank_site {
    my ($path) = @_;

    my $prev_path = Cwd::getcwd;
    chdir($path);

    mkdir for qw(_layouts _posts _drafts);
    open (my $fh, ">", "index.html");
    close($fh);

    chdir($prev_path);
}

sub scaffold_post_content {
    open my $f, '<', File::Spec->catfile(site_template(), $scaffold_path);
    local $/;
    my $content = App::Janet::Utils::parse_template(<$f>);
    close $f;

    return $content;
}

sub initialized_post_name {
    File::Spec->catfile('_posts',
        localtime->strftime('%Y-%m-%d') . '-welcome-to-jekyll.markdown');
}

sub create_sample_files {
    my ($path) = @_;

    dircopy(site_template(), $path);

    # Remove scaffold post file
    unlink File::Spec->catfile($path, $scaffold_path);
}

sub site_template {
    return File::Spec->catdir(File::Share::dist_dir('App-Janet'),
        'site_template');
}

1;
