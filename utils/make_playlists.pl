#!/usr/bin/perl
use strict;
use lib qw(/home/danil/projects/el/);
use el::Db;
use Config::General;
use Getopt::Compact;
use UNIVERSAL qw(isa);
use XML::XSPF;
use XML::XSPF::Track;
use Text::Iconv;
use URI::Escape;
#use Encode;
use Error qw(:try);


# Восстанавливает new_answers и mew_mails

my $o = new Getopt::Compact
  (#modes => [qw(debug)],
   usage=>1,
   struct =>
   [
    [[qw(d debug)], "SQL DEBUG MODE",'',\$el::Db::DEBUG],
   ]
  )->opts();

$|=1;

my $c = Text::Iconv->new("koi8-ru", "utf-8");
$c->raise_error(0);


my %config = Config::General::ParseConfig($ARGV[0] || '/home/danil/projects/nz/utils/convert.conf');

my $db = el::Db->new($config{database});

$db->sqlConnect() || die "Can't connect";


my $res = $db->sqlSelectOne("select count(*) as count from topic where not is_removed and music>0");
#print "$res->{count} topics to make playlists\n";
my $i = 0;
my $sth = $db->sqlQuery("select * from topic where not is_removed and music>0 order by id");
while (my $t = $sth->fetchrow_hashref()) {
	$i++;
	print "$i/$res->{count}: $t->{id} ";

	MakePlayList($t);
	print "done\n";
}


$db->sqlDisconnect();
#$db->sqlCommit();
print "ok\n";

sub MakePlayList {
	my $t = shift;
	my $dir = "/usr/local/www/mirror/zhazhda/pic/topics/$t->{id}";
	
	my $xspf  = XML::XSPF->new;
	$xspf->title(utf8($t->{subject}));
	$xspf->creator('dapi@zhazhda.ru');
	my $sth = $db->sqlQuery("select * from filesholder_file where type='music' and topic_id=$t->{id} order by id asc");
	my @t;
	
	while (my $f = $sth->fetchrow_hashref()) {
		my $track = XML::XSPF::Track->new;
		
		my $n = $f->{media_artist};
		$n="$n / " if $n;
		$n.=$f->{media_title};
		
		$track->title(utf8($n || $f->{file}));
		$track->location("http://zhazhda.ru/files/topics/$t->{id}/".uri_escape($f->{file}));
		push @t,$track;

		print '.';
	}
	$xspf->trackList(@t);
#	my $s = ;
	#	print "$s\n";
	my $file = "$dir/playlist.xspf";
	open(FILE, "> $file") || die "Can't open file $file ";
	
	print FILE $xspf->toString();
	close(FILE) || die "Can't close file $file ";
	
	
}


sub utf8 	{
	my ($s1,$s2) = @_;

#	$s1=~s/\00//g;
	$s1='..cant decode..' if $s1=~/\x01|\x02|\x03|\x04|\x05|\x06|\x07|\x08|\x09|\x10|\x11|\x12|\x13|\x14|\x15|\x16|\x17/;
	
	
	return $c->convert($s1);
	
}
	

