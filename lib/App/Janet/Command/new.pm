package App::Janet::Command::new;

use Cwd;
use File::Path qw(make_path);
use File::Spec;
use Moo;

sub process {
    my ($path) = @_;
    
    my $new_blog_path = File::Spec->rel2abs($path);

    make_path($new_blog_path);
    
    create_blank_site($new_blog_path);
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

1;
