#!/usr/bin/env perl
# vim: background=dark ts=4
#
# information_userのbodyカラムに混入しているCRLFをLFに全変換する
#
use DBI;

our $SCHEMA = 'aff';
our $USER   = 'mysql';
our $PWD    = 'EiV3X8q1';
our $HOST   = 'localhost';

our $TBL = 'information_user';
our $COLUMN = 'body';

my $dbh = dbConnect();
#$dbh->do("SET NAMES UTF8");
my $sth = $dbh->prepare("SELECT information_user_id, $COLUMN FROM $TBL LIMIT 200");
$sth->execute;
while (my $arr_ref = $sth->fetchrow_arrayref) {
		my ($id, $text) = @$arr_ref;
		if ($text =~ /\r\n/) {
			# CRLF -> '\n'
			$text =~ s/\r\n/\\n/mg;
		} elsif ($text =~ /\n/) {
			# LF -> '\n'
			$text =~ s/\n/\\n/mg;
		}
		$sql = "UPDATE $TBL SET $COLUMN='" . $text . "' where information_user_ID = $id";
		$dbhe>do($sql);
		if ($dbh->err) {
			print "[ERR](line=$linecnt) " . $dbh->errstr . " -> <$sql>\n";
		} else {
			#print "[OK](line=$linecnt)" .  $dbh->errstr . "-> <$sql>\n";
		}
}
$dbh->disconnect();
exit(0);
	


sub dbConnect {
	my $dbh = DBI->connect("DBI:mysql:dbname=${SCHEMA};host=${HOST}", $USER, $PWD);
	return $dbh;
}
