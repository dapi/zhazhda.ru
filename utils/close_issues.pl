#!/usr/bin/perl
use strict;
use lib qw(/home/danil/projects/el/);
use el::Db;
use GD;
use Config::General;
use Getopt::Compact;
use UNIVERSAL qw(isa);
use Date::Format;
use Date::Handler;
use Date::Parse;
use Date::Handler::Delta;
use Date::Language;

my $o = new Getopt::Compact
  (#modes => [qw(debug)],
   usage=>1,
   struct =>
   [
    [[qw(d debug)], "SQL DEBUG MODE",'',\$el::Db::DEBUG],
   ]
  )->opts();

$|=1;
#$el::Db::DEBUG=1;

# Перенести сюда обработку всяких sticky и days_to_list

my $today = new Date::Handler({ date => time,
                                time_zone => 'Europe/Moscow',
                                locale => 'ru_RU.KOI8-R'});

my %config = Config::General::ParseConfig($ARGV[0] || '/home/danil/projects/nz/utils/convert.conf');

my $db = el::Db->new($config{database});

$db->sqlConnect() || die "Can't connect";

my @m=('Январь','Февраль','Март','Апрель','Май','Июнь','Июль','Август','Сентябрь','Октябрь','Ноябрь','Декабрь');


# my $sth = $db->sqlQuery("select * from journal_topic");
# while (my $t = $sth->fetchrow_hashref()) {
#   sqlQuery("update topic set issue_id=? where topic_id=?",
#            $t->{issue_id},$t->{topic_id});
# };
#
# die 1;

#set_karma();
past_events();

my $sth = $db->sqlQuery("select * from journal");
while (my $j = $sth->fetchrow_hashref()) {
  check_hot($j);
  check_old($j);
}
$db->sqlCommit();

sub past_events {
  $db->sqlQuery("update topic set event_past='t' where journal_id is not null and not is_removed and topic_type='event' and not event_past and event_date<date(now())");
  $db->sqlQuery("update topic set event_past='f' where journal_id is not null and not is_removed and topic_type='event' and event_past and event_date>=date(now())");
}



sub set_karma {
  my %ht;
  my $sth = $db->sqlQuery("select topic.user_id, count(*) as count from journal_topic left join topic on topic.id=journal_topic.topic_id where topic_id=id and (is_hot or was_hot or is_on_top or was_top) group by user_id");
  while (my $t = $sth->fetchrow_hashref()) {
    $ht{$t->{user_id}}=$t->{count};
  }
  
  my $sth = $db->sqlQuery("select * from fuser where topics>0 and mobile_checked is not null and not is_removed");
  while (my $u = $sth->fetchrow_hashref()) {
    #my $karma = $u->{comments}/10;
    #        -$u->{blacked}*50;
    my $rb = $db->sqlSelect('select count(*) as count, sum(rating) as sum, sum(raters) as raters from topic where rating<=2.5 and raters>3 and user_id=?',$u->{id});
    my $rg = $db->sqlSelect('select count(*) as count, sum(rating) as sum, sum(raters) as raters from topic where rating>=4 and raters>3 and user_id=?',$u->{id});
    #my $rh = $db->sqlSelect('select count(*) as count from topic where (is_hot or was_hot or is_top or was_top) and user_id=?',$u->{id});
    
    my $r = $db->sqlSelect('select sum(subscribers) as sub, count(*) as count from topic where user_id=?',$u->{id});

    # Клубно-музыкальная
    my $karma1=$r->{sum}+$rg->{sum}-$rb->{count}+$u->{podcast_files}-$u->{blacked};

    # болтальщики
    my $karma2=$rg->{count}*2+$r->{sum}+$u->{topics}/10+$u->{comments}/100;

    # более объективная
#     my $karma3=$rg->{sum}-$rb->{sum}
#       +$u->{topics}/10
#         -$u->{blacked}
#           +$r->{sum}/5
#             +$u->{comments}/100;
#     #    my $karma = $ht{$u->{id}}+$karma3+$karma2/2+$karma1;#+$karma2+$karma3;
#     my $karma = $ht{$u->{id}}*1.5
#       +$rg->{count}
#         -$rb->{count}
#           +$r->{sub}/3
#             +$u->{podcast_files}/5
#               -$u->{blacked}
#                 +$u->{podcast_files}/5
#                   +$u->{topics}/1000
    #                     +$u->{comments}/10000;
    my $karma = $ht{$u->{id}}*10
      +$rg->{raters}
        -$rb->{raters}
          -$u->{blacked};
    $karma=int($karma);
    unless ($u->{karma}==$karma) {
      print "Change karma for $u->{login} from $u->{karma} to $karma\n";
      $db->sqlQuery('update fuser set karma=? where id=?',$karma,$u->{id});
    }
  }
}


sub check_hot {
  my $j = shift;
  my $sth = $db->sqlQuery("select topic.*, (create_time<(now() - interval '$j->{hot_days} days') or update_time<(now() - interval '$j->{hot_nonew_days} days')) as too_old from journal_topic left join topic on topic.id=journal_topic.topic_id where journal_topic.journal_id=? and is_hot and (topic_type<>'event' or event_past)",
                          $j->{id});
  while (my $t = $sth->fetchrow_hashref()) {
    next unless $t->{too_old};
    #    print "Remove hoting from topic $t->{id} $t->{create_time} $t->{update_time}\n";
    $db->sqlQuery("update journal_topic set is_hot='f', was_hot='t' where journal_id=? and topic_id=?",
                   $j->{id},$t->{id});
  }
  
  my $sth = $db->sqlQuery("select *, topic.topic_type, topic.event_past from journal_topic left join topic on topic.id=journal_topic.topic_id where topic_type='event' and event_past and journal_topic.journal_id=? and (is_hot or is_on_top)",
                          $j->{id});
  while (my $t = $sth->fetchrow_hashref()) {
#    print "$t->{id} $t->{is_on_main}/$t->{is_hot}/$t->{is_on_top} $t->{topic_type} $t->{event_past}\n";
    #next;
    $db->sqlQuery("update journal_topic set is_hot='f', was_hot='t' where topic_id=?",
                  $t->{id})
      if $t->{is_hot};
    $db->sqlQuery("update journal_topic set is_on_top='f', was_top='t' where topic_id=?",
                  $t->{id})
      if $t->{is_on_top};
  }

}

sub check_old {
  my $j = shift;
  $db->sqlQuery("update journal_topic set is_on_main='f' where timestamp<(now() - interval '$j->{days_to_list} days') and journal_id=? and is_on_main and not is_on_top and not is_hot",
                $j->{id});
}



sub tohandler {
  my $date = shift;
  return new Date::Handler({ date => str2time($date),
                             time_zone => 'Europe/Moscow',
                             locale => 'ru_RU.KOI8-R'});
}

sub next_dates {
  my ($j,$issue) = @_;
  die 'not implemente unless' unless $j->{issues_type}==1; # week
  my $date = tohandler($issue->{last_date} || '2006-12-31');
  my $delta1 = new Date::Handler::Delta([0,0,1,0,0,0]);
  my $delta7 = new Date::Handler::Delta([0,0,7,0,0,0]);
  my $first_date = $date + $delta1;
  my $last_date = $date + $delta7;
  if ($date->DayLightSavings() && !$first_date->DayLightSavings()) {
    $first_date = $first_date + $delta1;
    $last_date = $last_date + $delta7;
  }
#  print 'date'.."\n";
#  print 'first_date'.."\n";
#  print 'last_date'.$last_date->DayLightSavings()."\n";
  $first_date = $first_date->TimeFormat('%Y-%m-%d');
  $last_date = $last_date->TimeFormat('%Y-%m-%d');

#  print "($first_date,$last_date)\n";
  return ($first_date,$last_date);
}

sub nextday {
  my $date = tohandler(shift);
  my $delta1 = new Date::Handler::Delta([0,0,1,0,0,0]);
  return $date + $delta1;
}

sub increment_date {
  my $date = tohandler(shift);
  my $days = shift;
  my $delta1 = new Date::Handler::Delta([0,0,$days,0,0,0]);
  return $date + $delta1;
}


sub create_issue {
  my ($j,$first_date,$last_date) = @_;
  my $number = $db->sqlSelectOne("select max(number) as max from journal_issue where journal_id=?",$j->{id});
  $number = $number ? $number->{max}+1 : 1;
  my $title="#$number ($first_date-$last_date)";
  my $h = {journal_id=>$j->{id},
           first_date=>$first_date,
           number=>$number,
           topics=>0,
           # topics=>$topics,
           title=>$title,
           last_date=>$last_date};
  $h->{prev_id}=$j->{current_issue_id};
  my $id = $db->sqlInsert("journal_issue", $h, 'id');
  $db->sqlQuery('update journal set current_issue_id=? where id=?',
                $id,$j->{id});
  $db->sqlQuery('update journal_issue set next_id=? where id=?',
                $id,$j->{current_issue_id});
  $j->{current_issue_id}=$id;
  print "Create new journal issue '$j->{name}' #$number: $first_date - $last_date\n";
  return $db->sqlSelectOne('select * from journal_issue where id=?',$id);
}

sub move_topics {
  my ($j,$issue) = @_;
  $db->sqlQuery("lock table topic, journal_topic");
#   $db->
#     sqlQuery("update journal_topic set issue_id=? where (timestamp>=? and timestamp<?) and journal_id=?",
#              $issue->{id},$issue->{first_date},nextday($issue->{last_date}),$j->{id});
#
#   sqlQuery("update topic set issue_id=? where issue_id is NULL and id in (select topic_id from journal_topic where issue_id=?)",
#            $issue->{id},$issue->{id});

  my $sth = $db->sqlQuery("select * from journal_topic where issue_id=? and timestamp>=?",
                          $issue->{prev_id},
                          $issue->{first_date});
  my $count=0;
  print "Topics to move: ";
  while (my $t = $sth->fetchrow_hashref()) {
    $db->sqlQuery('update topic set issue_id=? where id=?',
                  $issue->{id},$t->{id});
    $db->sqlQuery('update journal_topic set issue_id=? where topic_id=?',
                  $issue->{id},$t->{id});
    $count++;
    #     $t->{issue_id}=$issue->{id};
    #     $t->{sticky_date}=
    #       increment_date($t->{timestamp},
    #                      $j->{days_to_list})
    #         unless $t->{sticky_date};
    #     $db->sqlInsert("topic_journal", $t);
  };

  print "$count\n";

  # Подсчитать колличество
  recount($issue->{id});
  recount($issue->{prev_id});
};

sub recount {
  my $id = shift;
  my $t = $db->
    sqlSelectOne('select count(*) as topics from journal_topic where issue_id=?',
                 $id);
  print "issue: $id, topics $t->{topics}\n";
  $db->
    sqlQuery("update journal_issue set topics=? where id=?",
             $t->{topics}+0,$id);

}

