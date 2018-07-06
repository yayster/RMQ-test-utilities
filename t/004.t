use strict;
use warnings;
use v5.22;
use Test::More;
use rabbitmq;

require_ok( 'rabbitmq' );
my $mo = new_ok( 'rabbitmq' );
done_testing();

