package nz::Journal::Foto;
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
  $self->activeItem('foto');
  $self->template_file('show_journal.html');
  $self->LoadGallery();
  my $j = $self->journal();
  
  $j->UpdateLastViewInfo();
  
  my $today = filter('date')->ToSQL(today());
  my @where;
  my @bind;
  
   push @where, "topic_type=?";
   push @bind, "gallery";
  
  return  {journal=>$j->Get(),
           topics=>$j->ListTopics({
                                   get_fotos=>1,
                                   where=>\@where,
                                   bind=>\@bind,
                                   order=>'event_date desc',
                                  }),
          };
}


1;
