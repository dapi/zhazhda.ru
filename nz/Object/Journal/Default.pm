package nz::Object::Journal::Default;
use strict;
use dpl::Web::Forum::Journal;
#use nz::Object::Journal::Afisha::Topic;
use Exporter;
use vars qw(@ISA
            @EXPORT);
@ISA=qw(Exporter
        dpl::Web::Forum::Journal);



# � ��� ��� ��������� ������� �
# ������ ����� ���� ��������������� ������� �������������

sub processor { 'journal' }

1;
