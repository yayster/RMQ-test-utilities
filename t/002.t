use strict;
use warnings;
use Test::More;
use rmq_utility;
use v5.22;

require_ok( 'rmq_utility' );
my $mo = new_ok( 'rmq_utility' );
is($mo->VERSION, 1.0, 'Correct version');
require_ok( 'Tk' );
require_ok( 'Tk::Optionmenu' );
require_ok( 'credentials' );
isa_ok( $mo->credentials, 'credentials' );
require_ok( 'rabbitmq' );
isa_ok( $mo->rmq, 'rabbitmq' );
isa_ok( $mo->rmq->rmq_core, 'Net::AMQP::RabbitMQ' );
$mo->credentials->initialize;
is($mo->credentials->HOSTNAME, 'localhost', 'Expected HOSTNAME');
done_testing();
