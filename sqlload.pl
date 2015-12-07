#!/usr/bin/env perl
# vim: background=dark ts=4
#
# ファイルを読み、中のSQL文を実行する。落ちた場合はSQL文の行番号を示す
# Usage: this.pl [sqlfile]
#
use DBI;
use Getopt::Long qw(:config posix_default no_ignore_case gnu_compat);
use Encode::Guess qw(cp932 shift-jis ascii utf8);
use Data::Dumper;

our $SCHEMA = 'aff';
our $USER   = 'mysql';
our $PWD    = 'EiV3X8q1';
our $HOST   = 'localhost';

GetOptions(
	"database=s" => \$SCHEMA,
	"user=s" => \$USER,
	"host=s" => \$HOST,
) or die "Undefined options\n";


# DB 接続
my $dbh = dbConnect();
$dbh.do("SET NAMES sjis");

# SQL文入りファイル読み込み
my $sql = '';
my $ctr = 1;	# 行カウンター
while (my $line = <>) {
	$ctr++;
	# ファイル中のコメント行読み飛ばし
	next if ($line =~ m|^/\*.*\*/|);

	# SQL文抽出
	my $seq;
	if ($seq = ($line =~ m/^(SELECT|INSERT|UPDATE|DELETE)/i .. $line =~ m/;\s*$/)) {
		# TEXT型カラムの改行処理
		if ($seq !~ /E0/) {		# $seqにE0が付くのは範囲マッチの最終行のみ
			if ($line =~ /\r\n$/ or $line =~ /\n$/) {
				$line =~ s/\r//g;
				$line =~ s/\n/\\n/g;
			}
		}
		$sql = join(' ', ($sql, $line));
	} 
	if ($seq =~ /E0/) {		# 範囲マッチング終了
		# SQL実行
		my $status = $dbh->do($sql);
		unless (defined($status)) {
			$ctr -= 1;
			print "[SQLERR:near line($ctr)] $sql IS FAILED!\n";
		}
		$sql = '';
	}
}

$dbh->disconnect;
exit(0);



##########################
# Subroutines
##

sub dbConnect {
	my $dbh = DBI->connect("DBI:mysql:dbname=${SCHEMA};host=${HOST}", $USER, $PWD);
	return $dbh;
}
