package Slash::Cache;

use strict;
use warnings;
use Slash::Utility;

my $drivers = {
	redis		=> 'Redis',
	memcache	=> 'Memcache',
};

sub new {
	my ($class, $options) = @_;

	my $driver = $class->_getDriver($options->{cache_driver});
	
	if(my $modname = $drivers->{$driver}) {
		my $cacheClass = "Slash::Cache::$modname";
		
		eval "use $cacheClass";
		if($@) {
			print "Unable to use $cacheClass: $@\n";
			return undef;
		}

		# Slash::Cache->new() returns an object of the preferred cache
		# class, never its own class.
		
		my $self = getObject($cacheClass, $options);

		return $self;
	}
	else {
		my $supported = join(', ', keys(%$drivers));
		print STDERR "driver $driver not supported! Supported drivers are: $supported.\n";
		return undef;
	}
}

sub _getDriver {
	my ($self, $driver) = @_;
	if($driver) { return $driver;}
	# default to the redis driver if none is specified
	else { return 'redis'; }
}

1;
