package nz::Ad;
use strict;
use Exporter;
use Date::Parse;
use dpl::Context;
use dpl::System;
use dpl::Base;
use dpl::Error;
use dpl::XML;
use dpl::Log;
use dpl::FilesHolder;
use dpl::Web::Forum;
use dpl::Db::Database;
use dpl::Db::Filter;
use dpl::Db::Table;
use dpl::DataType::Date;
use URI::Escape;

use dpl::Web::Forum::Processor::Base;
use vars qw(@ISA);
@ISA = qw(dpl::Web::Forum::Processor::Base);

sub ACTION_load_file {
  my $self = shift;
  files_holder()->
    UploadFile($self->param('dir_id'),
               $self->param('file'),
               $self->param('name'),
               $self->param('comment'));
  return 'ad/';
}


sub ACTION_create_dir {
  my $self = shift;
  files_holder()->CreateDir({map {$_=>''.$self->param($_)}
                             qw(parent_id name path comment)});
  return 'ad/';
}

sub ACTION_reklama {
}

sub ACTION_partner {
}


sub ACTION_default {
  my $self = shift;
  my $del = $self->param('del');
  files_holder()->RemoveFile($del)
    if $del;
  my $b = context('banners');
  my %b = (top=>{uri=>'/pic/banners/top_468x70.gif',
                 type=>'image',
                 width=>468, height=>70},
           splash=>{uri=>'/pic/banners/top_468x70.gif',
                    type=>'image',
                    width=>640, height=>480},
           bottom=>{uri=>'/pic/banners/bottom_468x70.gif',
                 type=>'image',
                 width=>468, height=>70},
           left01=>{uri=>'/pic/banners/ultra_120x90.gif',
                    type=>'image',
                    width=>120, height=>90},
           left02=>{uri=>'/pic/banners/ultra_120x90.gif',
                    type=>'image',
                    width=>120, height=>90},
           left03=>{uri=>'/pic/banners/ultra_120x90.gif',
                    type=>'image',
                    width=>120, height=>90},

           left04=>{uri=>'/pic/banners/econom_120x90.gif',
                    type=>'image',
                    width=>120, height=>90},
           left05=>{uri=>'/pic/banners/econom_120x90.gif',
                    type=>'image',
                    width=>120, height=>90},
           left06=>{uri=>'/pic/banners/econom_120x90.gif',
                    type=>'image',
                    width=>120, height=>90},


           left07=>{uri=>'/pic/banners/econom_120x90.gif',
                    type=>'image',
                    width=>120, height=>90},
           left08=>{uri=>'/pic/banners/econom_120x90.gif',
                    type=>'image',
                    width=>120, height=>90},
           left09=>{uri=>'/pic/banners/econom_120x90.gif',
                    type=>'image',
                    width=>120, height=>90},
           left10=>{uri=>'/pic/banners/econom_120x90.gif',
                    type=>'image',
                    width=>120, height=>90},
           left11=>{uri=>'/pic/banners/econom_120x90.gif',
                    type=>'image',
                    width=>120, height=>90},
           left12=>{uri=>'/pic/banners/econom_120x90.gif',
                    type=>'image',
                    width=>120, height=>90},
          );
  %$b=%b;
#  my $p = files_holder()->GetDir(5);
#  my $b = files_holder()->GetDir(6);
#  return {root=>files_holder()->GetDir(),
#          files=>[@{$p->{files}},@{$b->{files}}]
#         };
}


1;
