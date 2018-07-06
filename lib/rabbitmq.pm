package rabbitmq;

use strict;
use warnings;
use Moo;
use Net::AMQP::RabbitMQ;
use v5.22;
use Exception::Class;
use Try::Tiny;

has rmq_core => ( is => 'lazy',
                  builder => sub { Net::AMQP::RabbitMQ->new }, 
		  clearer => 1 );

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
    my $_count = shift || 0;
    try {
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
    catch {
	if( $_count == 3 ) {
	    die 'too many attempts';
	    CORE::exit(999);
	} else {
	    $_count++;
	    $self->clear_rmq_core;
	    $self->connect_to_broker( $host,
				      $username,
				      $password,
				      $port,
				      $heartbeat,
				      $_count
		);
	}
    }
}

sub disconnect_from_broker {
    my $self = shift;
    my $_count = shift || 0;
    try {
	unless( $_count ) {
	    $self->rmq_core->channel_close(1);
	    $self->rmq_core->disconnect();
	} else {
	    $self->clear_rmq_core;
	}
	return $self->rmq_core->is_connected;
    }
    catch {
    	if( $_count == 3 ) {
    	    die 'too many attempts';
    	    CORE::exit(999);
    	} else {
    	    $_count++;
    	    $self->disconnect_from_broker($_count);
    	}
    }
}

1;
