#!/usr/bin/env perl
# vim: background=dark ts=4
#
# 指定されたテーブルの指定カラムを全サーチしてASCIIでないPKEYを出力する
# Usage: this.pl --table=table --col=column
#
use DBI;
use Getopt::Long qw(:config posix_default no_ignore_case gnu_compat);
use Encode::Guess qw(cp932 shift-jis ascii utf8);
use Data::Dumper;

our $SCHEMA = 'aff';
our $USER   = 'mysql';
our $PWD    = 'EiV3X8q1';
our $HOST   = 'localhost';
our $TABLE  = '';
our @COLS   = ();

GetOptions(
	"database=s" => \$SCHEMA,
	"user=s" => \$USER,
	"host=s" => \$HOST,
	"table=s" => \$TABLE,
	"col=s" => \@COLS,
) or die "Undefined options\n";

# コマンド行引数チェック
if ($TABLE eq '' or @COLS <= 0) {
	die "[ERR] undefined table or columuns. set by --table or --col\n";
}

# DB 接続
my $dbh = dbConnect();
#$dbh->do("SET NAMES UTF8");

# 主キー取得
my @pkey = ();
my $sth = $dbh->prepare("DESC ${TABLE}");
$sth->execute();
while (my $ref = $sth->fetchrow_hashref()) {
	if ($ref->{'Key'} eq 'PRI') {
		push(@pkey, $ref->{'Field'});
	}
}
$sth->finish();

# SELECT文 作成
push(@pkey, @COLS);
my $sql = 'SELECT ' . join(",", @pkey);
$sql = "$sql FROM ${TABLE}";

# 指定されたカラムを読む
$sth = $dbh->prepare($sql);
$sth->{'mysql_use_result'} = 1;
$sth->execute();
while (my $ref = $sth->fetchrow_hashref()) {
	my $data = $ref->{$COLS[0]};
	next if $data eq '';

	# 文字コード判別
	my $enc = guess_encoding($data);
	if (ref($enc)) {
		# 確実に判定された
		if ($enc->name ne 'ascii') {
			# ASCIIでない
			print "$enc->name: ";
			print Dumper $ref;
			print "-------\n";
		}
	} else {
		# 判定があいまい
		print $enc . "\n";
		print Dumper $ref;
		print "-------\n";
	}
	last;
}
$sth->finish;
$dbh->disconnect;
exit(0);



##########################
# Subroutines
##

sub dbConnect {
	my $dbh = DBI->connect("DBI:mysql:dbname=${SCHEMA};host=${HOST}", $USER, $PWD);
	return $dbh;
}
