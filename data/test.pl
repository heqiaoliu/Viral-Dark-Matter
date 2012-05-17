#!/usr/bin/perl

use strict;
use warnings;
my $file = 'dir/upload/ID270-EDT2230.txt';
(my $file_short = $file ) =~ s/.*?\/upload\/(.*)/$1/i;
print "$file_short\n";
