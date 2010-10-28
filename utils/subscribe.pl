#!/usr/bin/perl
use strict;
use lib qw(
            /home/danil/projects/el/
            /home/danil/projects/nz/utils/
            /home/danil/projects/dpl/
            /home/danil/projects/dpl/littlesms/
         );
use el::Db;
use dpl::Db::Filter;
use Config::General;
use Date::Parse;
use Date::Format;
use Date::Handler;
use Text::Iconv;
use URI::Escape;
use HTTP::Lite;
use LittleSMS;


my @w=qw(пн вт ср чт пт сб вс);

$|=1;


my %config = Config::General::ParseConfig('/home/danil/projects/nz/utils/convert.conf');
my $db = el::Db->new($config{database});

$db->sqlConnect() || die "Can't connect";

my $messages = get_events('is_sms_sended');
send_to_users($messages,1,'zhazhda.ru:');

my $best = get_events('is_best_sms_sended',' and igos_counter>15');
send_to_users($best,2,'zhazhda.ru, best party:');


$db->sqlCommit();
$db->sqlDisconnect() || die "Can't connect";

sub send_to_users {
	my ($list,$et,$n) = @_;
	return unless $list && @$list;
	my $sth = $db->sqlQuery("select * from fuser where mobile_checked is not null and sms_event_type=$et");
	while (my $u = $sth->fetchrow_hashref()) {
		my $count=0;
		my $max = @$list;
		foreach my $m (@$list) {
			$count++;
			my $header = $#$list ? "[$count/$max] $n" : $n;
			SendSMS($u,"$header\n$m");
		}
	}
}

# 8:Прочее
# 2:Кино !
# 3:Театр !
# 4:Концерт !
# 5:Покатушки
# 6:Встреча
# 1:Клуб !
# 7:Выставка !
# 9:Кафе и рестораны !

sub get_events {
  my ($ss,$w) = @_;
  my @topics;
  my @events;
  my %dates;
  my $cats = join(' or ',map {"topic.place_category_id=$_"} qw(2 3 4 1 7 9));
  #  print "Subscribe ($s):\n";

  my @m;
  my $max=220;
  my $length=0;
  my $events_count=0;
  my %topics;
  my $q = qq(select topic.*, place.name as place, place_category.name as category
from topic
left join place on place.id=topic.place_id
left join place_category on place_category.id=topic.place_category_id
where topic_type='event' and not is_removed and topic.is_moderated and
topic.event_date>=now() and topic.event_date<=now()+ interval '7 days' and
journal_id is not null and not $ss and ($cats) order by event_date, event_time);

#	print STDERR "$q\n";
	
  my $sth = $db->sqlQuery($q);
  while (my $t = $sth->fetchrow_hashref()) {
#		next if $w && $t->{igos_counter}<10 && !IsTopicOnTop($t->{id});
    $t->{event_place}=$t->{place}
      unless $t->{event_place};
    $t->{event_time}=~s/\:00$//;
    
    $topics{$t->{id}}=$t;
    
    my $date = new Date::Handler({date=>str2time($t->{event_date}),
																	time_zone=>'Europe/Moscow',
                                  locale=>'ru_RU.KOI8-R'});
    my $w;
    
    my $str = $date->TimeFormat("%e %b (%a)");
    my $message;
    
    my $s = " $t->{event_time} [$t->{event_place}] $t->{subject}";
		$s=~s/&laquo;|&raquo;|&#(\d+);/"/g;
    $s=~s/['"*]//g;
    $s=~s/\s+$//g;
		
#   print "$str$s\n";
    if (@events && length($events[$#events])+length($s)<=$max) {
      $events[$#events].="\n$str$s";
    } else {
      push @events,"$str$s";
    }
  }

  foreach (keys %topics) {
      $db->sqlQuery("update topic set $ss='t' where id=?",$_);
  }
  
  return \@events;
}

sub IsTopicOnTop {
	my $tid = shift;
	my $res = $db->sqlSelectOne('select * from journal_topic where topic_id=? and is_on_top');
	return $res;
}

sub SendSMS {
  my ($user,$message) = @_;
	
  return undef unless $message;
  my $converter = Text::Iconv->new("koi8-r", "cp1251");
  #  return unless $user->{login} eq 'dapi';
#  print "$user->{login} ";
	$message=$converter->convert($message);
  $message=uri_escape($message);
	# print "($user->{login}) $message\n";
	
	#return 1 unless $user->{login} eq 'dapi';
	
  my $url = "http://www.shgsm.ru/esme/transmitter.php?id=DC16-847R&daddr=$user->{mobile}&msg=$message";
  my $http = new HTTP::Lite;
  my $req = $http->request($url) or return undef;
  my $res = $http->body();   #  print "URI: $url\n";
#	print "$url\n";
	
  print STDERR "Can't send sms to user $user->{id} - $user->{mobile}: $res\n"
    unless $res =~ /OK/;
  sleep(1);
  return 1;
}
