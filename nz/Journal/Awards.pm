package nz::Journal::Awards;
use strict;
use Exporter;
use nz::Utils;
use dpl::Context;
use dpl::System;
use dpl::Error;
use dpl::Db::Table;
use dpl::Db::Filter;
use dpl::Db::Database;
use nz::Journal::Default;
use vars qw(@ISA);
@ISA = qw(nz::Journal::Default);

sub processor { 'awards' }

sub ACTION_show_journal {
  my $self = shift;
  my $res = $self->SUPER::ACTION_show_journal();
  foreach (@{$res->{hot}}) {
    $_->{votes_list} = table('topic_vote')->List({topic_id=>$_->{id}});
  }
  return $res;
}

1;
