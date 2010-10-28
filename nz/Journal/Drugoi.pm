package nz::Journal::Drugoi;
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

sub LoadGallery {
  my ($self,$max) = @_;
  $max=20 unless $max;
  my @d=qw(23185 23179 23184 23186 23188 23182 23187);
  my $i = int(rand(@d));
  my $g = files_holder()->GetFiles({dir_id=>$d[$i]},$max);
  setContext('gallery',$g);
}


1;
