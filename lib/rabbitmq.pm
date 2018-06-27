package rabbitmq;

use strict;
use warnings;
use Moo;
use Net::AMQP::RabbitMQ;
use v5.22;

has rmq_core => ( is => 'lazy', );
sub _build_rmq_core {
    my $self = shift;
    return Net::AMQP::RabbitMQ->new();
}

sub send_heartbeat {
    my $self = shift;
    if( $self->rmq_core->is_connected ) {
	say time . "\t" . 'sending heartbeat';
	$self->rmq_core->heartbeat();
    }
}

sub connect_to_broker {
    my $self = shift;
    my $host = shift || 'localhost';
    my $username = shift || 'guest';
    my $password = shift || 'guest';
    my $port = shift || 5672;
    my $heartbeat = shift || 60;
    $self->rmq_core->connect( $host,
			  { port => $port,
			    user => $username,
			    password => $password,
			    heartbeat => $heartbeat
			  }
        ) || die "Cannot connect!\n";
    $self->rmq_core->channel_open(1);
    return $self->rmq_core->is_connected;
}

sub disconnect_from_broker {
    my $self = shift;
    $self->rmq_core->channel_close(1);
    $self->rmq_core->disconnect();
    return $self->rmq_core->is_connected;
}

1;
