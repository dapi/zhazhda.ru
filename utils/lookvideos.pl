#!/usr/bin/perl
use strict;
use LWP;
use lib qw(/home/danil/projects/el/);
use el::Db;
use dpl::Db::Filter;
use Config::General;
use Date::Parse;
use Date::Format;
use Date::Handler;
use Text::Iconv;
use URI::Escape;
use HTTP::Lite;
use URI::Split  qw(uri_split uri_join);

$|=1;
#$el::Db::DEBUG=1;
my %config = Config::General::ParseConfig('/home/danil/projects/nz/utils/convert.conf');
my $db = el::Db->new($config{database});
$db->sqlConnect() || die "Can't connect";
my %topics;

# Look in topics
print "Look in topics:";
my $vl='not videos_looked and ';

my $sth = $db->sqlQuery("select * from topic where $vl not is_removed and journal_id is not null order by id");
while (my $t = $sth->fetchrow_hashref()) {
	my $videos = LookForVideo($t->{text});
	print '.';
	
	if ($videos) {
		$db->sqlQuery('update topic set youtubes=? where id=?',scalar @$videos,$t->{id})
			unless $t->{youtubes}==scalar @$videos;
		SaveVideos($videos,$t,$t->{subject},$t->{id});
	}
	$topics{$t->{id}}=$t;
	
	$db->sqlQuery("update topic set videos_looked='t' where id=?",$t->{id});
	$db->sqlCommit();
}

#$db->sqlCommit();

print "\nLook in comments: ";
# Look in comments
my $sth = $db->sqlQuery("select * from comment where $vl vote_id is null order by id");
while (my $t = $sth->fetchrow_hashref()) {
	my $videos = LookForVideo($t->{text});
	print '.';
	$topics{$t->{topic_id}}=$db->sqlSelectOne('select * from topic where id=?',$t->{topic_id})
		unless $topics{$t->{topic_id}};
	
	SaveVideos($videos,$t,$topics{$t->{topic_id}}->{subject},$t->{topic_id},$t->{id})
		if $videos;
	$db->sqlQuery("update comment set videos_looked='t' where id=?",$t->{id});
	$db->sqlCommit();
}

print "\nDone.";

#$db->sqlCommit();


sub SaveVideos {
	my ($videos,$data,$title,$topic_id,$comment_id) = @_;
	foreach my $h (@$videos) {
		print "\n$h->{video_type}:$h->{video_id} $h->{link}\n";
		my $local_link="/topics/$topic_id.html";
		$local_link.="#m$comment_id" if $comment_id;
		$db->sqlInsert('videos',{timestamp=>$data->{create_time},
														 video_type=>$h->{video_type},
														 video_id=>$h->{video_id},
														 rutube_id=>$h->{rutube_id},
														 link=>$h->{link},
														 topic_id=>$topic_id,
														 image_src=>$h->{image_src},
														 image_width=>$h->{image_width},
														 image_height=>$h->{image_height},
														 title=>$title,
														 local_link=>$local_link,
														 comment_id=>$comment_id
														})
			unless $db->
				sqlSelectOne('select * from videos where topic_id=? and link=?',
										 $topic_id,
										 $h->{link});
	}

}

sub LookForVideo {
	my $text = shift;
	my @v;
	$text=~s/((((http):\/\/)|(www\.))([^\/][\@a-z0-9\._\+\-\=\?\&\%\,\/\#\(\)\;\:\~]+))/ProcessLink($1,\@v)/igme;
	return @v ? \@v : undef;
}

#rt_developer_key=0763e5f343d0cd6dc749d5c437737495

sub ProcessLink {
	my ($uri,$list) = @_;
	$uri="http://$uri" unless $uri=~m{(http[s]?|ftp)://};
  my ($scheme, $auth, $path, $query, $frag) = uri_split($uri);
  my $p = $path eq '/' ? '' : $path;
	
	my $link = uri_join($scheme, $auth, $path, $query);
	#	print "link1 $link ($auth, $path, $query)\n";
	
	# http://rutube.ru/tracks/1331141.html?v=431f1c37cc40953e4eed0ec5692f9562
  if ($auth=~/rutube\.ru$/ && $path=~/tracks\/(\d+)\.html/) {
		my $id = $1;

		if ($query=~/^v=([^&]+)$/) {
			my $vid = $1;

			#			my $image = GetRutubeImage($id);
			#			die "$link - $id - $vid - $image";
			my ($v1,$v2)=($vid=~/(..)(..)/);
			
			my $image="http://img-3.rutube.ru/thumbs/$v1/$v2/$vid-2.jpg";
#			die $image;
			push @$list, {link=>$link,
										video_type=>'rutube',
										image_src=>$image,
										image_width=>100,
										image_height=>75,
										rutube_id=>$vid,
										video_id=>$id};
		} else {
			print STDERR "!!! Strange rutube: $link\n";
			push @$list, {link=>$link,
										video_type=>'rutube',
										video_id=>$id};
		}
		#http://www.youtube.com/watch?v=tMANZ2iKRcQ
		#	print "$link\n";
		
  } elsif ($auth=~/youtube\.com$/ && $path eq '/watch' && $query=~/^v=([0-9a-z\-_]+)/i) {
		my $vid = $1;
    $link=~s/\&ytsession=.*//;
		push @$list, {link=>$link,
									image_src=>"http://i3.ytimg.com/vi/$vid/default.jpg",
									image_width=>120,
									image_height=>90,
									video_type=>'youtube',
									video_id=>$vid};
	} elsif ($auth=~/vimeo\.com$/ && $path=~/^\/(\d+)$/) {
		my $vid = $1;
#		my ($v1,$v2,$v3)=($vid=~/(..)(..)(..)/); my
		#		$image="http://images.vimeo.com/$v1/$v2/$v3/$vid/$vid"."_100.jpg"; 
		my $image='/pic/space.gif';
		
		push @$list, {link=>$link,
									image_src=>$image,
									image_width=>100,
									image_height=>75,
									video_type=>'vimeo',
									video_id=>$vid};
  }

}


sub GetRutubeImage {
	my ($id) = @_;
	
}
