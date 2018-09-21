#!/usr/bin/perl -w

#TODO: add paramters to allow direct file processing, and re

# cmd-line parameters
# -soh  print SOH character; SOH is shown as | by default;
# -hb   show Heartbeat/TestRequest messages; filtered by default;
# -alt1:"" comma separated list of tags that can be highlighted in the alt color 1 (e.g. tags of particular interest)
# -alt2:"" comma separated list of tags that can be highlighted in the alt color 2 (e.g. tags of particular interest)

use strict;

our $SOH = "\x01";
our $NONE = undef;
our $BOLD = -1;
our $BLACK = 30;
our $RED = 31;
our $GREEN = 32;
our $YELLOW = 33;
our $BLUE = 34;
our $MAGENTA = 35;
our $CYAN = 36;
our $WHITE = 37;
our ($mdid, $mdstart);

# $re - regex indicating presence of arg; any non-whitespace after $re will be returned;
sub getArgValue {
    my($re) = @_;
    my $retval;
    foreach my $arg (@ARGV) {
        if ($arg =~ m/${re}/) {
            if (defined($1)) {
                $retval = $1;
            } else {
                $retval = -1;
            }
            last;
        }
    }
    $retval;
}

our (%priceMap, %qtyMap);
our $FORMAT = "%-8s %-12s %-7s %02s %-6s %-3s %-10s %-8s %-s\n";
sub colTitles() {
        printf $FORMAT,
                "Seq", "Time", "Ccy/Ccy", "No", "Action", "B/A", "Qty", "Price", "MDEntryId";
    print "-------- ------------ ------- -- ------ --- ---------- -------- --------------\n";
}

sub printMD() {
        my ($seq, $time, $ccy, $num, $mda, $bo, $qty, $px, $id) = @_;
        printf $FORMAT,
                $seq, $time, $ccy, $num, &action($mda), &bidAsk($bo), $qty, $px, $id;
}

sub action() {
        my $a = shift;
        return $a eq '0'  ? 'New'
                : $a eq '1' ? 'Change'
                : $a eq '2' ? 'Delete'
                : 'Tick';
}

sub bidAsk() {
    my $ba = shift;
        return ! defined $ba ? ""
            : $ba eq "0"
                ? "Bid" : "Ask";
}

&colTitles;
while (defined(my $line = <STDIN>)) {
        my ($mtype, $mdhead, $seq, $time, $ccy, $mda, $bo, $qty, $px, $num, $mdata, $id);

        # only want market data
        ($mtype) = ($line =~ /35=([WX])/);
        next unless defined $mtype;

        #print "$line\n";

        ($seq, $time, $ccy) = ($line =~ /34=(\d+)?${SOH}.*?52=\d{8}-(.+?)${SOH}.*?${SOH}?55=(.{7})/);
        die "ERROR -->> [$line]\n" unless defined $seq && defined $time && defined $ccy;

        ($num,$mdata) = ($line =~ /268=(\d+)${SOH}(.+)${SOH}10=/);
        $mdid = $mtype eq 'W' ? '299' : '278';
        $mdstart = $mtype eq 'W' ? '269' : '279';

        # extract each MD entry from $mdata
        my $n = 1;
        while (defined($mdata)) {
                #print "mdata=$mdata\n";
                ($mda) = ($mdata =~ /279=([012])/);
                ($bo) = ($mdata =~ /269=([01])/);
                ($id) = ($mdata =~ /${mdid}=(\w+)/);
                ($px) = ($mdata =~ /270=(.+?)${SOH}/);
                ($qty) = ($mdata =~ /271=(.+?)${SOH}/);
                $mda = 'X' if $mtype eq 'W';
                die "ERROR -->> [$mdata]\n" unless defined $mda && defined $id;

                # remember/recall
                if ($mtype eq 'W') {
                        if ($mda eq '2') {
                                $px = $priceMap{$id};
                                $qty = $qtyMap{$id};
                                $px = "?" if ! defined $px;
                                $qty = "?" if ! defined $qty;
                        }
                        else {
                                $priceMap{$id} = $px;
                                $qtyMap{$id} = $qty;
                        }
                }

                #print "$seq, $time, $ccy, $mda, $bo, $qty, $px, $id\n";
                &printMD($seq, $time, $ccy, $n++, $mda, $bo, $qty, $px, $id);
                $seq = $time = $ccy = "";

        # skip to the next MDEntry
                my $pos = index($mdata, "$mdstart=", 1);
                last if $pos == -1;
                $mdata = substr($mdata, $pos);
        }
}

