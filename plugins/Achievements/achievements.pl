#!/usr/local/bin/perl -w
# This code is a part of Slash, and is released under the GPL.
# Copyright 1997-2009 by Open Source Technology Group. See README
# and COPYING for more information, or see http://slashcode.com/.

use strict;

use Slash;
use Slash::Constants ':slashd';
use Slash::Utility;

use vars qw(%task $me $task_exit_flag);

$task{$me}{timespec} = '0 3 * * *';
$task{$me}{fork} = SLASHD_NOWAIT;
$task{$me}{code} = sub {
	my($virtual_user, $constants, $slashdb, $user) = @_;

	my $achievements = getObject('Slash::Achievements');
	return 'Achievements not installed, aborting' unless $achievements;
	$achievements->getScore5Comments();

	return;
};

1;
