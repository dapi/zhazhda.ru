#!/usr/bin/perl
use strict;
use lib qw(/home/danil/projects/el/);
use el::Db;
use Config::General;
use Getopt::Compact;
use UNIVERSAL qw(isa);
#use dpl::Web::define;
use dpl::Log;
use dpl::Config;
use dpl::Error;
use dpl::Context;
use dpl::Base;
use dpl::XML;
use dpl::System;
use dpl::Web::Forum::Escape;

dpl::System::Define('nz','/home/danil/projects/nz/system.xml');

setting('uri',{home=>'http://zhazhda.ru/',
               pic=>'http://zhazhda.ru/pic'});

#use nz::define;
use lib qw(/home/danil/projects/
           /home/danil/projects/nz/);

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

$db->sqlConnect() || die "Can't connect";

my $sth = $db->sqlQuery("select * from fuser order by id");
while (my $t = $sth->fetchrow_hashref()) {
  
#  my $e=dpl::Web::Forum::Escape::filter_escape_text($t->{text});
  my $e = lc($t->{email});
  
  $e=~s/^\s+//g;
  $e=~s/\s+$//g;
  print "$t->{id} ";
  
  
  $db->sqlQuery('update fuser set email=? where id=?',$e,$t->{id});
  print "$e\n";
  $db->sqlCommit();
}



print "ok\n";

