package rmq_utility;

use strict;
use warnings;
use Moo;
use Tk;
use Tk::Optionmenu;
use credentials;
use rabbitmq;
use v5.22;
    
has VERSION => (
    is => 'ro',
    default => 1.0,
    );

has mw => ( is => 'lazy', );
sub _build_mw {
    my $self = shift;
    return MainWindow->new();
}

has mf => ( is => 'lazy', );
sub _build_mf {
    my $self = shift;
    return $self->mw->Frame( -height => 300,
			     -width  => 500,
	);
}

has credentials => ( is => 'lazy', );
sub _build_credentials {
    my $self = shift;
    return credentials->new;
}

has rmq => ( is => 'lazy', );
sub _build_rmq {
    my $self = shift;
    return rabbitmq->new;
}

sub initialize {
    my $self = shift;
    my $title = shift || 'unknown';
    # Tried to use has-generated method to hold these variables, but they did not work.
    $self->{message} = "Rabbitmq Utilities\n\n(c) Copyright 2018 - David N. Kayal";
    $self->{connection_flag} = 0;
    $self->mw->title( 'RMQ Utilities: ' . $title );
    $self->credentials->initialize;
    $self->connection_toggle;
    $self->select_host;
    $self->connection_status_indicator;
    $self->message_area;
    $self->done;
    $self->mf->pack();
    $self->mw->repeat( $self->credentials->HEARTBEAT * 1000,sub { $self->rmq->send_heartbeat } );
    $self->mw->repeat( 1000, sub{ $self->check_connection } );
}

sub check_connection {
    my $self = shift;
    if( $self->{ connection_flag } ) {
	print time . "\t" . 'checking connection' . "\t";
	$self->{connection_flag} = '0' unless( length $self->rmq->rmq_core->is_connected );
	print $self->rmq->rmq_core->is_connected . "\t";
	print $self->{connection_flag} . "\n";
    }
}

sub done {
    my $self = shift;
    $self->mf->Button(  -text => "Done",
			-command => sub{ exit },
			-height => 1,
			-width  => 10,
	)->place( -anchor => 'se',
		  -y => 280,
		  -x => 480,
	    );
}    

sub select_host {
    my $self = shift;
    $self->mf->Optionmenu(
        -options => $self->credentials->hosts,
        -command => sub {
	    my $_new_host = shift;
	    $self->credentials->update_credentials( $_new_host ) 
	},
	-variable => \$self->credentials->host,
	-textvariable => \$self->credentials->host,
	-height => 1,
	-width  => 20,
    )->place( -anchor => 'ne',
	      -y => 5,
	      -x => 340,
    );
}

sub connection_toggle {
    my $self = shift;
    $self->mf->Button(  -text => 'Toggle Connection',
			-command => sub{ 
			    print time . "\t" . 'toggle' . "\t" . $self->{connection_flag} . "\t";
			    if( $self->{connection_flag} ) {
				print 'Disconnecting from ' . $self->credentials->HOSTNAME . "\t";
				$self->{connection_flag} = '0' unless( length $self->rmq->disconnect_from_broker );
			    } else {
				print 'Connecting to ' . $self->credentials->HOSTNAME . "\t";
				$self->{connection_flag} = 
				    $self->rmq->connect_to_broker( $self->credentials->HOSTNAME,
								   $self->credentials->LOGIN,
								   $self->credentials->PASSWORD,
								   $self->credentials->PORT,
								   $self->credentials->HEARTBEAT
				    );
			    }
			    print $self->{connection_flag} . "\n";
			},
			-height => 1,
			-width  => 15,
	)->place( -anchor => 'ne',
		  -y => 5,
		  -x => 155,
	    );
}    

sub connection_status_indicator {
    my $self = shift;
    $self->mf->Checkbutton( -text => 'Connected',
			    -height => 1,
			    -width => 10,
			    -variable => \$self->{connection_flag},
			    -state => 'disabled',
			    -disabledforeground => '#27d85f'
	)->place( -anchor => 'ne',
		  -y => 10,
		  -x => 480,
	);
}

sub message_area {
    my $self = shift;
    $self->mf->Label(   -textvariable => \$self->{message},
			-borderwidth => 2,
			-width => 65,
			-height => 10,
			-relief => 'groove',
			-justify => 'left',
	)->place( -anchor => 'nw',
		  -y => 40,
		  -x => 20,
	    );    
}

1;
