#!/usr/bin/env perl
# vim: background=dark ts=4
use strict;
use Encode::Guess qw/ascii cp932 euc-jp 7bit-jis shiftjis utf8/;
use Data::Dumper;

#
# リレーログを引数で受け取り、cp932, sjisの箇所をUTF8に変換してstdoutに出力する
#

while (<>) {
	my $g = Encode::Guess::guess_encoding($_, qw/shiftjis 7bit-jis utf8 cp932/) ;
	if (ref($g)) {
		my $enc = $g->name;
		if ($enc == 'ascii') {
			print $_;
		} elsif ($enc == 'cp932' or $enc == 'shiftjis' or $enc == 'euc-jp') {
			my $decoded_str = decode($enc, $_);
			print encode('utf-8', $decoded_str);
		}
	} else {
		if ($g == 'shiftjis or cp932') {
			my $decoded_str = Encode::decode('cp932', $_);
			##print "[cp932] ";
			print Encode::encode('utf-8', $decoded_str);
		} else {
			die "[ERR!] encode = $g\n";
		}
	}
}

