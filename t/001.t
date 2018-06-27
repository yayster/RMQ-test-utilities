use strict;
use warnings;
use Test::Simple tests => 24;

&path_tests( 'bin', 1, 0, 1 );
&path_tests( 'bin/basic', 1, 1, 0);
&path_tests( 'lib', 1, 0, 1 );
&path_tests( 'lib/rmq_utility.pm', 1, 1, 0 );
&path_tests( 'lib/credentials.pm', 1, 1, 0 );
&path_tests( 'lib/rabbitmq.pm', 1, 1, 0 );
&path_tests( 'conf', 1, 0, 1 );
&path_tests( 'conf/credentials.yml', 1, 1, 0 );

sub path_tests {
    my $test_path      = shift;
    my $expected_one   = shift;
    my $expected_two   = shift;
    my $expected_three = shift;
    my $result_one   = -e $test_path;
    my $result_two   = -f $test_path;
    my $result_three = -d $test_path;
    ok($result_one   == $expected_one, $test_path . " exist test");
    ok($result_two   == $expected_two, $test_path . " file test");
    ok($result_three == $expected_three, $test_path . " directory test");
}
