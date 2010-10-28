package nz::Journal::Video;
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

sub FAKE_template_file {
  my ($self,$file) = @_;
	return $self->{template_file} = 'journal/video/show_journal.html';
#	return  = "journal/video/$file";
}


sub ACTION_show_journal {
  my $self = shift;

	$self->addNav('journal');
  $self->activeItem('video');
  $self->template_file('show_journal.html');

  my $j = $self->journal();
  $j->UpdateLastViewInfo();
	#die $j->Get('templ_path');
	
	my $limit = 20;
	my $count = db()->SelectAndFetchOne('select count(*) as count from videos')->{count};
	my $pages=int($count/$limit); 	$pages++ if $pages*$limit<$count;	
	
	my $page = $self->param('page');
	$page=$pages if $page>$pages || !$page;
	$page=1 if $page<1;
	$page=$pages if $page>$pages;
	
	my $start = ($page-1)*$limit;
	
  my $videos = db()->SelectAndFetchAll("select * from videos order by timestamp asc limit $limit offset $start");
#  my $s = $self->session();
 
  return  {journal=>$j->Get(),
					 videos=>$videos,
					 pages=>$pages,
					 page=>$page,
					 count=>$count
					}
};


1;
