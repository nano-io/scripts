#!/usr/bin/perl -w

#2018-09-21 02:26:04,633 8=FIX.4.49=27535=W34=296163349=B2C2MD52=20180921-02:26:04.63356=d5c81248d5916b9d212f69a930e3b31a552fd53f55=XRPUSD.CFD262=XRPUSD.CFD-OZHubSubscribe268=4269=1270=0.46008271=3562.1416269=1270=0.46008271=17810.7078269=0270=0.45899271=3562.1416269=0270=0.45891271=17810.707810=155

use strict;
use warnings;

my (%tick, $d, $t, $u, $sym, $k);

## collection phase
while (<>) {
    next unless /35=W/;
    #print $_;
    ($d, $t, $u, $sym) = ($_ =~ /^(.{10}) (.{12}).+?56=(.+?)\x01.*?55=(\w{6})/);
    # truncate all ids to 20 chars
    $u = substr($u, 0, 20);
    $k = "$u $sym $t";
    $tick{$k}++;
}

# analysis phase
my $sym0 = "";
my $t0 = 0;
my ($gap, $h, $m, $s, $ms, $tx);
foreach my $k (sort keys %tick) {
    ($u, $sym, $t) = split / /, $k;
    ($h, $m, $s) = split /:/, $t;
    ($s, $ms) = split /,/, $s;
    $tx = ($h * 60 * 60 * 1000) + ($m * 60 * 1000) + ($s * 1000) + $ms;
    $gap = $sym eq $sym0 ? $tx - $t0 : 0;
    print "$u $sym $h:$m:$s $tick{$k} $gap\n" if $gap > 2000;
    $sym0 = $sym;
    $t0 = $tx;
}

