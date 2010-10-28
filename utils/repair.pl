#!/usr/bin/perl
use strict;
use lib qw(/home/danil/projects/el/);
use el::Db;
use GD;
use Config::General;
use Getopt::Compact;
use UNIVERSAL qw(isa);

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



my %config = Config::General::ParseConfig($ARGV[0] || '/home/danil/projects/nz/utils/convert.conf');

my $db = el::Db->new($config{database});
#my $db2 = el::Db->new($config{database2});

$db->sqlConnect() || die "Can't connect";

#$db2->sqlConnect() || die "Can't connect";

#issues();
#youtubes();
#links();
#$db->sqlCommit();


sub youtubes {
  my $sth = $db->sqlQuery("select * from topic");
  while (my $t = $sth->fetchrow_hashref()) {
    next
      unless $t->{text}=~/youtube\.com\/watch/;
    $db->sqlQuery('update topic set youtubes=1 where id=?',
                  $t->{id}
                 );
    print "$t->{id} ";
  }
}



sub links {
  my $sth = $db->sqlQuery("select * from topic where not is_removed and journal_id is not NULL and id not in (select topic_id from journal_topic where journal_topic.journal_id=topic.journal_id)");
  while (my $t = $sth->fetchrow_hashref()) {
    
    $db->sqlQuery('insert into journal_topic values (?,?)',
                  $t->{journal_id},
                  $t->{id}
                 );
    print "$t->{journal_id}-$t->{id}\n";
  }
}


my $errors = 0;

my $j = $db->sqlQuery("select * from journal for update");
my $sth = $db->sqlQuery("select count(*) as count, journal_id from journal_topic group by journal_id");
while (my $t = $sth->fetchrow_hashref()) {
  next unless $t->{journal_id};
  my $j = $db->sqlSelectOne('select * from journal where id=?',$t->{journal_id});
  unless ($j->{topics}==$t->{count}) {
    $errors++;
    $db->sqlQuery("update journal set topics=? where id=?",$t->{count},$t->{journal_id});
  }
}
print "topics count in journal $errors\n" if $errors;
$errors=0;

# TODO топики с journal_id/journals но не в journal_topic

my $sth = $db->sqlQuery("select * from topic where journal_id is null and id in (select topic_id from journal_topic)");
while (my $t = $sth->fetchrow_hashref()) {
  $errors++;
  $db->sqlQuery("update topic set journal_id=? where id=?",1,$t->{id});
}
print "topic whithout journal_id $errors\n" if $errors;

$errors=0;


my $sth = $db->sqlQuery("select count(*) as count, topic_id from journal_topic  group by topic_id");
while (my $j = $sth->fetchrow_hashref()) {
  my $t = $db->sqlSelectOne('select * from topic where id=?',$j->{topic_id});
  next if $t->{journals}==$j->{count};
  $errors++;
  $db->sqlQuery("update topic set journals=? where id=?",$j->{count},$j->{topic_id});
}
print "journals count in topic $errors\n" if $errors;

$errors=0;



$db->sqlCommit();
$db->sqlQuery('set transaction isolation level serializable');

#print "load users: ";
my %users;
my @users;
my $sth = $db->sqlQuery("select * from fuser order by id for update");
while (my $u = $sth->fetchrow_hashref()) {
  $users{$u->{id}}=$u;
  push @users,$u;
}

#print "ok\n";

my $sth = $db->sqlQuery("select user_id, sum(new_answers) as new_answers from topic_views where topic_id not in (select id from topic where is_removed or journal_id is NULL) group by user_id");
while (my $u = $sth->fetchrow_hashref()) {
  $users{$u->{user_id}}->{new_answers_real}=$u->{new_answers}+0;
}

$sth = $db->sqlQuery("select user_id, count(*) as count from topic where journal_id is null and not is_removed group by user_id");
while (my $u = $sth->fetchrow_hashref()) {
  $users{$u->{user_id}}->{draft_topics_real}=$u->{count}+0;
}

$sth = $db->sqlQuery("select user_id, sum(new_mail) as new_mail from mail_box group by user_id");
while (my $u = $sth->fetchrow_hashref()) {
  $users{$u->{user_id}}->{new_mail_real}=$u->{new_mail};
}

$sth = $db->sqlQuery("select user_id, count(*) as topics from topic where journal_id is not null group by user_id");
while (my $u = $sth->fetchrow_hashref()) {
  $users{$u->{user_id}}->{topics_real}=$u->{topics}+0;
}


my %errors;



foreach my $id (keys %users) {
  my %h=();
  my $u = $users{$id};

  unless ($u->{new_mail}==$u->{new_mail_real}) {
    $errors{new_mail}++;
    $db->sqlQuery("update fuser set new_mail=? where id=?",
                  $u->{new_mail_real},$id);
  }

  unless ($u->{draft_topics}==$u->{draft_topics_real}) {
    $errors{draft}++;
    #    print "$id $u->{draft_topics}==$u->{draft_topics_real}\n";
    $db->sqlQuery("update fuser set draft_topics=? where id=?",
                  $u->{draft_topics_real}+0,$id);
  }

  unless ($u->{new_answers}==$u->{new_answers_real}) {
    $errors{new_answer}++;
    $db->sqlQuery("update fuser set new_answers=? where id=?",
                  $u->{new_answers_real}+0,$id);
  }

  unless ($u->{topics}==$u->{topics_real}) {
    $errors{topics}++;
    $db->sqlQuery("update fuser set topics=? where id=?",
                  $u->{topics_real}+0,$id);
  }
}

#print "ok\n";

print "new_answers errors: $errors{answer}\n"
  if $errors{answer};
print "draft_topics errors: $errors{draft}\n"
  if $errors{draft};
print "new_mail errors: $errors{mail}\n"
  if $errors{mail};
print "topic errors: $errors{topic}\n"
  if $errors{topic};





# print "clear categories topic counter\n";
# my $sth = $db->sqlQuery("select * from topic_category order by id for update");
# while (my $c = $sth->fetchrow_hashref()) {
#   my $res = $db->sqlSelectOne("select count(*) as topics from topic where category_id=?",$c->{id});
#   if ($c->{topics}!=$res->{topics}) {
#     print "#$c->{id} ($c->{name}): $c->{topics}!=$res->{topics}\n";
#     $db->sqlQuery("update topic_category set topics=? where id=?",$res->{topics},$c->{id});
#   }
# }
# print "ok\n";



# TODO удалять удаленные темы
print "clear subscribes and blacks";
foreach my $u (@users) {
  print '.';
  my $res = $db->sqlSelectOne("select count(*) as fresh_topics from topic_views where is_freshed and user_id=?",$u->{id});
  if ($u->{fresh_topics}!=$res->{fresh_topics}) {
    print "\nsubscribe $u->{id}: $u->{fresh_topics}!=$res->{fresh_topics}\n";
    $db->sqlQuery("update fuser set fresh_topics=? where id=?",$res->{fresh_topics},$u->{id});
  }

  # всегда я в поряде
#   my $res = $db->sqlSelectOne("select count(*) as blacked from blacks where black_id=?",$u->{id});
#   if ($u->{blacked}!=$res->{blacked}) {
#     print "\nblack $u->{id}: $u->{blacked}!=$res->{blacked}\n";
#     $db->sqlQuery("update fuser set blacked=? where id=?",$res->{blacked},$u->{id});
  #   }
}
$db->sqlCommit();
print "ok\n";

