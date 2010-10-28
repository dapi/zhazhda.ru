package nz::Mail;
use strict;
use Exporter;
#use Date::Parse;
#use Math::Random;
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

sub lookup {
  my ($self,$query) = @_;
  return 1 unless $self->{page}->{action} eq 'exchange';

  # Ищем юзверя
  my $messages = $query=~s/\/messages$/\//;
  my $clear = $query=~s/\/clear$/\//;
  return undef unless $query=~s/\/$//;
#  die "$messages" if $messages;
  if ($self->{talker}=table('fuser')->Load({login=>uri_unescape($query)})) {
    setContext('talker',$self->{talker});
    $self->{page}->{action}='messages' if $messages;
    $self->{page}->{action}='clear' if $clear;
    return 1;
  } else {
    $self->{page}->{action}='notfound';
    return 1;
  }

}

sub ACTION_mail {
  my $self = shift;
  $self->addNav('mail');
  return {new=>$self->user()->GetNewMailIndex(),
          archive=>$self->user()->GetMailArchive()};
}

sub ACTION_post {
  my $self = shift;
  return undef
    unless
      $self->CheckReferer('Вы действительно желаете разместить письмо?');

  my $talker = $self->param('talker');
  my $r = $self->user()
    ->SendPrivateMail($self->param('uid') || $talker,
                      $self->param('message')
                     );
  fatal("Message sent to SMS users") if $r eq '@sms';
  fatal("Такого пользователя нет $talker") unless $r;
  return "user/".uri_escape($r->{login})."/mail";
}


1;
