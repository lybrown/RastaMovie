#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;

my $debug = 0;

sub frame {
    my ($label, $org, $samples) = @_;
    print "\torg $label\n" if $org;
    print "\t:[$label-*] dta 0\n" if not $org;
    print "\tsta WSYNC\n";
    my $loadoffset = 0;
    my $playoffset = 248;
    for my $i (0 .. 12) {
        my $s = 0;
	my $n = $playoffset > 255 ? 8 : 7;
        my $d = $debug ? " ; s=$s n=$n" : "";
        print "\tmva audio+$playoffset AUDC1$d\n";
        $playoffset += 1;
        $s += $n;
        for my $j (0 .. 18) {
            my $sample = ord substr $samples, $loadoffset, 1;
            my $d = $debug ? " ; s=$s n=5" : "";
            printf "\tmva #\$%02X audio+$loadoffset$d\n", $sample;
            $loadoffset += 1;
            $s += 5;
        }
	if ($playoffset > 255) {
            my $d = $debug ? " ; s=$s n=2" : "";
	    print "\tnop$d\n";
	    $s += 2;
	} else {
            my $d = $debug ? " ; s=$s n=3" : "";
	    print "\tcmp 0$d\n";
	    $s += 3;
	}
    }
    my $s = 0;
    my $d = $debug ? " ; s=$s n=8" : "";
    print "\tmva audio+$playoffset AUDC1$d\n";
    $playoffset += 1;
    $s += 8;
    for my $j (0 .. 14) {
        my $sample = ord substr $samples, $loadoffset, 1;
        my $n = $loadoffset > 255 ? 6 : 5;
        my $d = $debug ? " ; s=$s n=$n" : "";
        printf "\tmva #\$%02X audio+$loadoffset$d\n", $sample;
        $loadoffset += 1;
        $s += $n;
    }
    print "\trts\n";
    $s += 3;
}

sub gen {
    my ($offset, $org, $file) = @_;
    open my $fh, $file or die "ERROR: Cannot open $file: $!\n";
    seek $fh, $offset, 0;
    my $count = read $fh, my $samples, 262*2;
    if ($count != 262*2) {
        die "ERROR: Could not read 262*2 bytes at offset $offset in $file.\n";
    }
    frame("loadaudio1", $org, substr $samples, 0, 262);
    frame("loadaudio2", $org, substr $samples, 262, 262);
}

sub main {
    my $offset;
    my $org;
    GetOptions(
        "offset:0" => \$offset,
        "org!" => \$org,
    );
    @ARGV or die "Usage: genaudio.pl [--offset <offset>] audio.raw\n";
    gen($offset, $org, $ARGV[0] || "/dev/stdin");
}

main();
