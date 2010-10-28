package nz::Files;
use strict;
use Exporter;
use nz::Utils;
# use Date::Parse;
use dpl::Context;
use dpl::Db::Table;
use dpl::Db::Database;

use dpl::Web::Forum::Processor::Base;
use vars qw(@ISA);
@ISA = qw(dpl::Web::Forum::Processor::Base);

sub lookup {
  my ($self,$query) = @_;
  if ($self->{page}->{action} eq 'show_file') {
    if ($query=~/^(\d+).html$/) {
      return $self->loadFile($1);
    } else {
      return undef;
    }
  }
  #   }
  #   my %actions = $self->_actions();
  #   return 1 if $self->{page}->{action}=$actions{$query};
  #   $self->{page}->{action}='notfound';
  return 1;
}

sub loadFile {
  my ($self,$file_id)=@_;
  my $file = table('filesholder_file')->Load($file_id);
  $self->{file_id}=$file_id;
  return undef unless $file;
  $file->{topic} = $self->LoadTopicAndInitJournal($file->{topic_id})
    || die("No such topic $file->{topic_id}");
  return $self->{file}=$file;
}

sub ACTION_remove_file {
  my $self =shift;
  return undef
    unless
      $self->CheckReferer('Вы действительно желаете удалить файл?');

  my $file_id = $self->param('id');
  my $h = setting('files_holder');
  my $f = $h->GetFile($file_id) || fatal("No such file $file_id");

  $h->RemoveFile($file_id);

  return $f->{next} ? "/holder/$f->{next}->{id}.html#photo" : "/topics/$f->{topic_id}.html";
}


sub ACTION_remove_gallery {
  my $self =shift;
  return undef
    unless
      $self->CheckReferer('Вы действительно желаете удалить файл из галлери?');
  my $file_id = $self->param('id');
  table('filesholder_file')->
    Modify({is_in_gallery=>0},
           $file_id);

  my $h = setting('files_holder');
  my $f = $h->GetFile($file_id);
  return $f->{next} ? "/holder/$f->{next}->{id}.html#photo" : "/holder/$file_id.html#photo";
}

sub ACTION_put_gallery {
  my $self =shift;
  return undef
    unless
      $self->CheckReferer('Вы действительно желаете разместить файл в галлерее?');
  my $file_id = $self->param('id');
  #  forum()->PutFileInGallery($file_id);
  table('filesholder_file')->
    Modify({is_in_gallery=>1,
            is_moderated=>1},
           $file_id);

  my $h = setting('files_holder');
  my $f = $h->GetFile($file_id);
  return $f->{next} ? "/holder/$f->{next}->{id}.html#photo" : "/holder/$file_id.html#photo";
}


sub ACTION_set_moderated {
  my $self =shift;
  return undef
    unless
      $self->CheckReferer('Вы действительно желаете?');

  my $file_id = $self->param('id');
  my $tid = $self->param('topic_id');
  
  if ($tid) {
    table('filesholder_file')->
      Modify({is_moderated=>1},
             {topic_id=>$tid});
  } else {
    table('filesholder_file')->
      Modify({is_moderated=>1},
             $file_id);
  }
  
  db()->Commit();
  return "/holder/$file_id.html#photo";
  

}

sub ACTION_remove_moderated {
  my $self =shift;
  return undef
    unless
      $self->CheckReferer('Вы действительно желаете?');
  my $file_id = $self->param('id');
  table('filesholder_file')->
    Modify({is_moderated=>0},
           $file_id);
  db()->Commit();
  return "/holder/$file_id.html#photo";
}




sub ACTION_show_file {
  my $self = shift;
  my $me = $self->param('me');
  die "No topic" unless $self->{topic_instance};
  setContext('topic',$self->{topic});
  $self->{topic_instance}->AddPersone($self->{file_id}) if $me;
  my $d = $self->param('delete_persone');
  $self->{topic_instance}->
    RemovePersone($self->{file_id},$d) if $d;
  return $self->{topic_instance}->ShowFile($self->{file_id});
}

sub ACTION_edit_file {
  my $self = shift;
  return undef
    unless
      $self->CheckReferer('Вы действительно желаете?');
  my $f = forum()->files_holder();
  my $id = $self->param('id');
  my $file = $f->GetFile($id) || fatal("No such file");
  setContext('topic',$self->{topic} = $self->LoadTopicAndInitJournal($file->{topic_id}));
  my $res = $self->{topic_instance}->ShowFile($file->{id});
  return $res;
}

sub ACTION_edit_file_post {
  my $self = shift;
  return undef
    unless
      $self->CheckReferer('Вы действительно желаете?');
  my $f = forum()->files_holder();
  my $id = $self->param('id');
  my $file = $f->GetFile($id) || fatal("No such file");
  table('filesholder_file')->Modify({title=>$self->param('title')},$id);
  db()->Commit();
  return "/holder/$file->{id}.html#photo";
}



1;
