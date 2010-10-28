package nz::Journal::Afisha;
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



sub ACTION_show_journal {
  my $self = shift;
  $self->addNav('journal');
  $self->activeItem('afisha');
  $self->template_file('show_journal.html');
  $self->LoadGallery();
  my $j = $self->journal();
  
  $j->UpdateLastViewInfo();
  
  my $today = filter('date')->ToSQL(today());
  my @where;
  my @bind;
  
  push @where, "event_date>=?";
  push @bind, $today;
  
  return  {journal=>$j->Get(),
           topics=>$j->ListTopics({where=>\@where,
                                   bind=>\@bind,
                                   order=>'event_date, event_time',
                                  }),
          };
}


1;
