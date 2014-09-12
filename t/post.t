use strict;
use warnings;

use Test::More;

use App::Janet::Post;

subtest 'Check if valid post names are recognized' => sub {
    ok(App::Janet::Post->valid('2014-09-12-foo-bar.textile'));
    ok(App::Janet::Post->valid('foo/bar/2014-09-12-foo-bar.textile'));
};

subtest 'Check if invalid post names are rejected' => sub {
    ok(!App::Janet::Post->valid('foo2014-09-12-foo-bar.textile'));
    ok(!App::Janet::Post->valid('bogus'));
};

done_testing;
