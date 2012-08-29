#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;

sub frame {
    my ($label, $samples) = @_;
    print "\torg $label\n";
    print "\tsta WSYNC\n";
    my $loadoffset = 0;
    my $playoffset = 248;
    for my $i (0 .. 12) {
        my $s = 0;
	my $n = $playoffset > 255 ? 8 : 7;
        print "\tmva audio+$playoffset AUDC1 ; s=$s n=$n\n";
        $playoffset += 1;
        $s += $n;
        for my $j (0 .. 18) {
            my $sample = ord substr $samples, $loadoffset, 1;
            printf "\tmva #\$%02X audio+$loadoffset ; s=$s n=5\n", $sample;
            $loadoffset += 1;
            $s += 5;
        }
	if ($playoffset > 255) {
	    print "\tnop ; s=$s n=2\n";
	    $s += 2;
	} else {
	    print "\tcmp 0 ; s=$s n=3\n";
	    $s += 3;
	}
    }
    my $s = 0;
    print "\tmva audio+$playoffset AUDC1 ; s=$s n=8\n";
    $playoffset += 1;
    $s += 8;
    for my $j (0 .. 14) {
        my $sample = ord substr $samples, $loadoffset, 1;
        my $n = $loadoffset > 255 ? 6 : 5;
        printf "\tmva #\$%02X audio+$loadoffset ; s=$s n=$n\n", $sample;
        $loadoffset += 1;
        $s += $n;
    }
    print "\trts\n";
    $s += 3;
}

sub gen {
    my ($offset, $file) = @_;
    open my $fh, $file or die "ERROR: Cannot open $file: $!\n";
    seek $fh, $offset, 0;
    my $count = read $fh, my $samples, 262*2;
    if ($count != 262*2) {
        die "ERROR: Could not read 262*2 bytes at offset $offset in $file.\n";
    }
    frame("loadaudio1", substr $samples, 0, 262);
    frame("loadaudio2", substr $samples, 262, 262);
}

sub main {
    my $offset;
    GetOptions(
        "offset:0" => \$offset,
    );
    @ARGV or die "Usage: genaudio.pl [--offset <offset>] audio.raw\n";
    gen($offset, $ARGV[0] || "/dev/stdin");
}

main();
