package nz::Object::Journal::Afisha;
use strict;
use dpl::Web::Forum::Journal;
use nz::Object::Journal::Afisha::Topic;
use Exporter;
use vars qw(@ISA
            @EXPORT);
@ISA=qw(Exporter
        nz::Object::Journal::Default
       );

#sub classTopic { 'nz::Object::Journal::Afisha::Topic'}

# sub init {
#   my ($self,$forum,$data) = @_;
#   $self->SUPER::init($forum,$data);
# #  $self->{topic_table}='topic_afisha';
#   return $self;
# }

sub processor { 'afisha' }

# У нас нет отдельной горячки и
# анонсы должн быть соответствующим образом сгруппированы

sub ShowJournal {
  die 'ShowJournal is not defined in Afisha';
}


1;
