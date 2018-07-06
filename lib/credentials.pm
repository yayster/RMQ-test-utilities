package credentials;

use strict;
use warnings;
use Moo;
use YAML::Tiny;
use v5.22;
use experimental 'smartmatch';
use Data::Dumper;

has VERSION => (
    is => 'ro',
    default => 1.0,
    );

has yaml_file => (
    is => 'ro',
    default => 'conf/credentials.yml',
    );

has yaml => ( is => 'lazy', );
sub _build_yaml {
    my $self = shift;
    return YAML::Tiny->read( $self->yaml_file );
}

has hosts => ( is => 'lazy', );
sub _build_hosts {
    my $self = shift;
    my %_hash = %{$self->yaml->[0]};
    my @_array = sort( keys %_hash );
    return \@_array;
}

has HOSTNAME => ( is => 'rw', default => 'unknown' );
has PORT => ( is => 'rw', default => 5672 );
has LOGIN => ( is => 'rw', default => 'unknown' );
has PASSWORD => ( is => 'rw', default => 'unknown' );
has HEARTBEAT => ( is => 'rw', default => 60 );

has host => ( is => 'rw', default => 'unknown' );

sub update_credentials {
    my $self = shift;
    my $host = shift || 'unknown';
    say "Setting credentials for $host.";
    die "$host does not exist in " . $self->yaml_file unless( $host ~~ $self->hosts );
    my %_hash = %{$self->yaml->[0]{$host}};
    my @_credentials = ( 'HOSTNAME', 'PORT', 'LOGIN', 'PASSWORD', 'HEARTBEAT' );
    foreach my $_credential ( @_credentials ) {
	$self->$_credential( $_hash{ $_credential } ) if( length $_hash{ $_credential } );
    }
    $self->host( $host );
    return( $self->host );
}

sub initialize {
    my $self = shift;
    say $self->host;
    $self->host( ${ $self->hosts}[0] );
    say $self->host;
    return( $self->update_credentials( $self->host ) );
}

1;
