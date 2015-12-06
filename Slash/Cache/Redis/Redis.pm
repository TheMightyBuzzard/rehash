# This package abstracts Redis module calls so we can use the same calls no matter what
# cache module we are using.
package Slash::Cache::Redis;

use strict;
use warnings;
use Redis;
use base 'Slash::Cache';

sub new {
	my ($class, $options) = @_;
	if ($class->can('isInstalled')) {
		return undef unless $class->isInstalled();
	}
	my $self = {
		r => Redis->new( server => $class->_getServer(),
				cnx_timeout => 1,
				read_timeout => 0.5,
				write_timeout => 0.5,
		),
		expires	=> $class->_getDefaultExpire(),
		_options => $options,
	};
	bless $self, $class;
	return $self;
}

sub get {
	my ($self, $key) = @_;
	return $self->{r}->get($key);
}

sub set {
	# $expires is in seconds
	my ($self, $key, $value, $expires) = @_;
	$expires ||= $self->{expires};
	return $self->{r}->set($key, $value, 'EX', $expires);
}

sub delete {
	my ($self, $key) = @_;
	# You can actually delete multiple keys by joining an array with a space character
	# but we aren't going to use that functionality right now for compatibility reasons.
	return $self->{r}->del($key);
}

sub stats {
	my ($self) = @_;
	my $info = $self->{r}->info();
	# set cache_type. this needs to be done for any cache module so we know what type we have when we're
	# displaying cache stats on the admin page.
	$info->{cache_type} = 'redis';
	return $info;
}

sub isInstalled { 1; }

sub _getServer {
	my ($self) = @_;
	if($self->{_options}->{no_getcurrentstatic}) {
		my $slashdb = getCurrentDB();
		my $answer = $slashdb->sqlSelectHashref("redis_host, redis_port", "vars");
		# You must set both the host and the port in the vars table or we use the defaults
		unless( $answer->{redis_host} && $answer->{redis_port} ) {
			return "localhost:6379";
		}
		return $answer->{redis_host}.":".$answer->{redis_port};
	}
	else{
		$host = getCurrentStatic("redis_host");
		$port = getCurrentStatic("redis_port");
		# You must set both the host and the port in the vars table or we use the defaults
		unless($host && $port) { return "localhost:6379"; }
		return "$host:$port";
	}
	return "$host:$port";
}

sub _getDefaultExpire {
	my ($self) = @_;
	if($self->{_options}->{no_getcurrentstatic}) {
		my $slashdb = getCurrentDB();
		my $expires = $slashdb->sqlSelect("redis_expires", "vars");
		return ( $expires || 600 );
	}
	else {
		return ( getCurrentStatic("redis_expires") || 600 );
	}
}

1;
