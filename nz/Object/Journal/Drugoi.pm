package nz::Object::Journal::Drugoi;
use strict;
use dpl::Web::Forum::Journal;
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

sub processor { 'drugoi' }

1;
