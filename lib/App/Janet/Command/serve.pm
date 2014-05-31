package App::Janet::Command::serve;

use strict;
use warnings;

use Getopt::Long qw(GetOptionsFromArray);
use HTTP::Server::PSGI;
use Moo;
use Plack::Builder;
use URI;

extends 'App::Janet::Command';

sub process {
    my ($class, $options, @args) = @_;

    GetOptionsFromArray(\@args,
        'port=i'    => \$options->{port},
        'host=s'    => \$options->{host},
        'baseurl=s' => \$options->{baseurl}
    );

    my $config = $class->configuration_from_options($options);

    my $server = HTTP::Server::PSGI->new(
        host => $config->{host},
        port => $config->{port},
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
