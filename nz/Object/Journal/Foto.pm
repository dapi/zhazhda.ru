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

# � ��� ��� ��������� ������� �
# ������ ����� ���� ��������������� ������� �������������

sub ShowJournal {
  die 'ShowJournal is not defined in Afisha';
}


1;
