package App::Janet::Command::serve;

use strict;
use warnings;

use Getopt::Long qw(GetOptionsFromArray);
use HTTP::Server::PSGI;
use Plack::Builder;
use URI;

my %options = (
    port => undef,
    host => undef,
);

sub process {
    GetOptionsFromArray(\@_,
        'port' => \$options{port},
        'host' => \$options{host}
    );

    my $server = HTTP::Server::PSGI->new(
        host => $options{host},
        port => $options{port},
        timeout => 120,
    );

    my $app = builder {
        enable sub {
            my $app = shift;

            sub {
                my $env = shift;

                my $path_uri = URI->new($env->{'PATH_INFO'});
                if ($path_uri->path eq '/') {
                    # If path is "/", serve index.html
                    $path_uri->path('/index.html');
                }
                $env->{'PATH_INFO'} = $path_uri->as_string;
                
                return $app->($env);
            }
        };
        
        enable "Plack::Middleware::Static",
            path => '/',
            root => '_site';
    };

    $server->run($app);
}

1;
