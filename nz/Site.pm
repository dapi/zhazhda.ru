package nz::Site;
use strict;
use YAML;
use URI::Escape;
use dpl::Db::Database;
use dpl::Web::Forum::Site;
use dpl::System;
use dpl::Context;
use dpl::Web::Forum::Journal;
use nz::Utils;
use Error qw(:try);
use Scalar::Util 'blessed';
use vars qw(@ISA
            @EXPORT);
@ISA = qw(dpl::Web::Forum::Site);

sub init {
  my $self = shift;
  #,$node,$home,$path) = @_;
  $self = $self->SUPER::init(@_);

  setting('dir')->{template}=setting('dir')->{template_org};

  setting('dir')->{template}=setting('dir')->{template_dev}
    if setting('uri')->{home}=~/test\.zhazhda/;

  setting('dir')->{template}=setting('dir')->{template_pda}
    if setting('uri')->{home}=~/pda\.zhazhda/;

#  db()->Connect();
  return $self;
}


sub lookup {
  my ($self,$path) = @_;
  $self->preparePaths($path) || return undef;
  #  db()->Connect();
#   $server->hostname($self->{r}->get_server_name);
#     $server->port($self->{r}->get_server_port);
#     $server->scheme('http');
#    die    $server->unparse;
#    $uri{current} = $server;

  my $host = setting('uri')->{current}->hostname();
#   if ($host=~/drugoisport/) {
#     $host='drugoisport.ru';
#     setting('community','drugoisport');
#   } else {
    $host='zhazhda.ru';
    setting('community','zhazhda');
  #  }
  #print STDERR "host: $host\n";
  setting('host',$host);
  if ($self->{page}->{container} eq 'journal') {
    if ($self->{page}->{tail}=~s/^([^\/]+\/)// || !$self->{page}->{tail}) {
      my $j = forum()->LoadJournalByLink($host,$1);
      return undef unless $j;
      my $ji = JournalInstance($j);
      $self->{page}->{processor}=$ji->processor();# прописывается начиная с nz::Journal::Default
      $self->{processor} = $self->lookupProcessor($self->{page}->{processor});
   
      $self->{processor}->initJournal($j,$ji);
      return $self->{processor}->lookup($self->{page}->{tail});
    } else {
      return undef
    }
  }
  $self->{processor} = $self->lookupProcessor($self->{page}->{processor});
  return $self->{processor}->lookup($self->{page}->{tail});
}

1;
