package nz::Object::Journal::Foto;
use strict;
use dpl::Web::Forum::Journal;
use Exporter;
use vars qw(@ISA
            @EXPORT);
@ISA=qw(Exporter
        nz::Object::Journal::Default
       );

sub processor { 'foto' }

# У нас нет отдельной горячки и
# анонсы должн быть соответствующим образом сгруппированы

sub ShowJournal {
  die 'ShowJournal is not defined in Afisha';
}


1;
