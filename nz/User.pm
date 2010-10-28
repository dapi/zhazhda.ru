package nz::User;
use strict;
use Exporter;
use dpl::Context;
use dpl::System;
use dpl::Base;
use dpl::Error;
use dpl::XML;
use dpl::Log;
use dpl::Db::Database;
use dpl::Db::Filter;
use dpl::Db::Table;
use URI::Escape;

use dpl::Web::Forum::Processor::Base;
use vars qw(@ISA);
@ISA = qw(dpl::Web::Forum::Processor::Base);


# Процессор действует с яужими профилями пользователей

sub lookup {
  my ($self,$query) = @_;
#    return undef if $self->{page}->{action} eq 'show_login' && !$self->user()->IsLoaded();
  return 1 unless $self->{page}->{action} eq 'home';#
#  die $self->{page}->{action};

  #||  $self->{page}->{action} eq 'avatar';
  my ($login,$action)=($query=~/([^\/]+)\/(.*)/);
  $action='podcast_rss' if $action eq 'podcast/rss.xml';
  $action='feed_rss' if $action eq 'feed/rss.xml';
  $self->{page}->{action}=$action || 'home';
  $self->{talker}=table('fuser')->Load({login=>uri_unescape($login)});
  return undef unless setContext('talker',$self->{talker});
  $self->newMails();
  return 1;
}

sub ACTION_show_login {
	
}

sub ACTION_podcast {
  my $self = shift;
  $self->addNav('user','user_podcast');
  $self->template('user_podcast');
}

sub ACTION_podcast_rss {
  my $self = shift;
  my $pic = setting('uri')->{home}.'pic';
  my $image = $self->{talker}->{thumb_file} ?
    "$pic/users/$self->{talker}->{thumb_file}"
      : '$pic/birka.gif';
  $self->template('podcast_rss');
  my $title = $self->{talker}->{podcast_name};
  $title="ìÉÞÎÙÊ podcast $self->{talker}->{login} ÎÁ zhazhda.ru"
    unless $title;
  return {items=>$self->get_music(),
          link=>setting('uri')->{home}.'user/'.uri_escape($self->{talker}->{login}).'/podcast/rss.xml',
          author=>$self->{talker}->{login},
          title=>$title,
          image=>$image,
          description=>$self->{talker}->{podcast_comment}};
}

sub ACTION_feed_rss {
  my $self = shift;
  print STDERR "feed_rss action\n";
  
  my $pic = setting('uri')->{home}.'pic';
  my $image = $self->{talker}->{thumb_file} ?
    "$pic/users/$self->{talker}->{thumb_file}"
      : '$pic/birka.gif';
  $self->template('feed_rss');
  my $title = $self->{talker}->{podcast_name};
  $title="$self->{talker}->{login} ÎÁ zhazhda.ru"
    unless $title;
  my $topics = dpl::Web::Forum::_listTopics({where=>
                                            ['topic.user_id=?','not topic.is_removed and topic.journal_id is not null'],
                                             bind=>
                                             [$self->{talker}->{id}],
                                             limit=>50});
  

  return {topics=>$topics,
          link=>setting('uri')->{home}.'user/'.uri_escape($self->{talker}->{login}).'/feed/rss.xml',
          author=>$self->{talker}->{login},
          title=>$title,
          image=>$image};
}


sub newMails {
  my $self = shift;
  return undef unless $self->user()->IsLoaded();
  return undef unless $self->user()->Get('new_mail');
  setContext('new_talker_mails',
             $self->user()->HasNewMailsOfUser($self->{talker}->{id}));
}

sub ACTION_mail {
  my $self = shift;
  $self->addNav('mail','talker');
  $self->template('exchange');
  return {talker=>$self->{talker},
          pages=>$self->user()->GetPrivateMailsPages($self->{talker}->{id})};
}

sub ACTION_clear_mail {
  my $self = shift;
  return undef
    unless
      $self->CheckReferer('÷Ù ÄÅÊÓÔ×ÉÔÅÌØÎÏ ÖÅÌÁÅÔÅ ÏÞÉÓÔÉÔØ ÐÏÞÔÏ×ÙÊ ÑÝÉË?');

  my $r = $self->user()->ClearPrivateMail($self->{talker}->{id});
  $self->template('redirect');
  return "/user/".uri_escape($self->{talker}->{login})."/mail";
}



sub ACTION_messages {
  my $self = shift;
  my $r = $self->user()->GetPrivateMails($self->{talker}->{id},$self->param('page'));
  $self->template('messages');
  $r->{talker} = $self->{talker};
  return $r;
}

sub ACTION_home {
  my $self = shift;
  $self->addNav('user','user_home');
  my $i = db()->
    SelectAndFetchAll("select * from files_persons where user_id=$self->{talker}->{id} limit 20");
  my @images;
  foreach (@$i) {
    my $a = db()->
      SelectAndFetchOne("select * from filesholder_file where id=$_->{file_id} and type='image' and is_moderated");
    push @images,$a
      if $a;
  }
  return {
          images=>\@images,
          list=>dpl::Web::Forum::_listTopics({where=>
                                              ['topic.user_id=?','not topic.is_removed and topic.journal_id is not null'],
                                              bind=>
                                              [$self->{talker}->{id}]}),

         }
}

sub ACTION_profile {
  my $self = shift;
  $self->addNav('user','user_profile');
  $self->template('user_profile');
  return {blacks=>db()->
              SuperSelectAndFetchAll("select $dpl::Web::Forum::user_fields from fuser where fuser.id in (select user_id from blacks where black_id=?)",
                                     $self->{talker}->{id})};
}

sub ACTION_foto {
  my $self = shift;
  $self->addNav('user','user_foto');
  my $i = db()->
    SelectAndFetchAll("select * from files_persons where user_id=$self->{talker}->{id}");
  my @images;
  foreach (@$i) {
    my $a = db()->
      SelectAndFetchOne("select * from filesholder_file where id=$_->{file_id} and type='image' and is_moderated");
    push @images,$a
      if $a;
  }
  $self->template('user_foto');
  return {
          images=>\@images,
         }
}


sub ACTION_avatar {
  my $self = shift;
  $self->addNav('user','user_avatar');
  $self->template('avatar');
}


1;
