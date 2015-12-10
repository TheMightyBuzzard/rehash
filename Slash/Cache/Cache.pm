package Slash::Cache;

use warnings;
use Slash::Utility;

my $drivers = {
	redis		=> 'Redis',
	memcache	=> 'Memcache',
};

sub new {
	my ($class, $options) = @_;

	my $driver = _getDriver($options->{cache_driver});

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

		return bless $self, $cacheClass;
	}
	else {
		my $supported = join(', ', keys(%$drivers));
		print STDERR "driver $options->{cache_driver} not supported! Supported drivers are: $supported.\n";
		return undef;
	}
}

sub isInstalled {
	return 1;
}

sub _getDriver {
	my ($self, $driver) = @_;
	if($driver) {
		return $driver;
	}
	# default to the redis driver if none is specified
	else { return 'redis'; }
}

1;
