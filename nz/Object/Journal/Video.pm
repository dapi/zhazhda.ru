package nz::Object::Journal::Video;
use strict;
use dpl::Web::Forum::Journal;
use Exporter;
use vars qw(@ISA
            @EXPORT);
@ISA=qw(Exporter
        nz::Object::Journal::Default);

sub processor { 'video'; }

# � ��� ��� ��������� ������� �
# ������ ����� ���� ��������������� ������� �������������

sub ShowJournal {
  die 'ShowJournal is not defined in Video';
}


1;
