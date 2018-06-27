use strict;
use warnings;
use Test::More;
use credentials;
use Data::Dumper;
use v5.22;

require_ok( 'credentials' );
my $mo = new_ok( 'credentials' );
is($mo->VERSION, 1.0, 'Correct version');
is($mo->yaml_file, 'conf/credentials.yml', 'expected credentials file');
require_ok( 'YAML::Tiny' );
isa_ok($mo->yaml,'ARRAY');
isa_ok( $mo->hosts, 'ARRAY');
is( $mo->host, 'localhost', 'expected default host' );
#say Dumper( $mo->yaml );
#say Dumper( $mo->yaml->[0]{$mo->host} );
$mo->update_credentials( $mo->host );
is( $mo->HOSTNAME, 'localhost', 'expected HOSTNAME' );
is( $mo->PORT, 5672, 'expected PORT' );
is( $mo->LOGIN, 'guest', 'expected LOGIN' );
is( $mo->PASSWORD, 'guest', 'expected PASSWORD' );

done_testing;
