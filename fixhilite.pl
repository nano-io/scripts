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

# $s  - string containing (SOH delimited) FIX message
# $re - regex to match
# $fg - foreground color from above table
# $bg - background color from above table
# $b  - bold
sub colorizeTag {
    my($s, $re, $fg, $bg, $b);
    ($s, $re, $fg, $bg, $b) = @_;
    if (defined($b)) {
        if (defined($bg)) {
            $bg = $bg + 10;
            $s =~ s/${SOH}(${re})${SOH}/${SOH}\033[1m\e[${fg};${bg}m${1}\e[0m\033[0m${SOH}/g;
        } else {
            $s =~ s/${SOH}(${re})${SOH}/${SOH}\033[1m\e[${fg}m${1}\e[0m\033[0m${SOH}/g;
        }
    } else {
        if (defined($bg)) {
            $bg = $bg + 10;
            $s =~ s/${SOH}(${re})${SOH}/${SOH}\e[${fg};${bg}m${1}\e[0m${SOH}/g;
        } else {
            $s =~ s/${SOH}(${re})${SOH}/${SOH}\e[${fg}m${1}\e[0m${SOH}/g;
        }
    }
    $s;
}

# $s    - string containing (SOH delimited) FIX message
# $tags - comma separated list of tags to colorize
# $fg   - foreground color from above table
# $bg   - background color from above table
# $b    - bold
sub colorizeTags {
    my($s, $tags, $fg, $bg, $b);
    ($s, $tags, $fg, $bg, $b) = @_;
    foreach my $tag (split(',', $tags)) {
        $s = colorizeTag($s, "${tag}=[^${SOH}]*", $fg, $bg, $b);
    }
    $s;
}

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

our $arg_hb = &getArgValue("-hb");
our $arg_soh = &getArgValue("-soh");;
our $arg_alt1 = &getArgValue("-alt1:([^\\s]+)");
our $arg_alt2 = &getArgValue("-alt2:([^\\s]+)");
our $arg_alt3 = &getArgValue("-alt3:([^\\s]+)");
our $arg_alt4 = &getArgValue("-alt4:([^\\s]+)");

while (defined(my $line = <STDIN>)) {

    if ($line =~ m/${SOH}35=[^01]/ || $arg_hb && $line =~ m/${SOH}35=/) {

        # message types
        $line = &colorizeTag($line, "35=[D]", $BLACK, $GREEN);
        $line = &colorizeTag($line, "35=[8]", $BLACK, $YELLOW);
        $line = &colorizeTag($line, "35=[A0-5]", $BLACK, $CYAN);
        $line = &colorizeTag($line, "35=[3j9Y]", $BLACK, $RED);
        $line = &colorizeTag($line, "35=[^${SOH}]*", $BLACK, $MAGENTA);

        # alerts
        $line = &colorizeTag($line, "39=8", $RED, $NONE, $BOLD);
        $line = &colorizeTag($line, "150=8", $RED, $NONE, $BOLD);
        $line = &colorizeTags($line, "43,97,45,379,380", $RED, $NONE, $BOLD);

        # alt tags:
        if (defined($arg_alt1)) {
            $line = &colorizeTags($line, $arg_alt1, $BLACK, $WHITE);
        }
        if (defined($arg_alt2)) {
            $line = &colorizeTags($line, $arg_alt2, $BLACK, $RED);
        }
        if (defined($arg_alt3)) {
            $line = &colorizeTags($line, $arg_alt3, $BLACK, $CYAN);
        }
        if (defined($arg_alt4)) {
            $line = &colorizeTags($line, $arg_alt4, $BLACK, $MAGENTA);
        }

        # correlation
        $line = &colorizeTags($line, "11,41,17,37,70,198,526,571,572,664,772", $BLUE, $NONE, $BOLD);

        # order
        $line = &colorizeTags($line, "40,21,55,48,22,207,15,100,54,59,44,38", $GREEN, $NONE, $BOLD);

        # exec reports
        $line = &colorizeTags($line, "6,14,20,32,44,151,39,150,58", $YELLOW, $NONE, $BOLD);

        # replace SOH with | by default
        if (!defined($arg_soh)) {
            $line =~ s/\|/\;/g;
            $line =~ s/${SOH}/\|/g;
        }

        print $line;
    }
}

