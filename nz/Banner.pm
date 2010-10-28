package nz::Banner;
use strict;
use Exporter;
use Date::Parse;
use GD;
use dpl::Error;
use dpl::Context;
use dpl::Db::Database;
use dpl::Web::Banner;
use dpl::DataType::DateObject;
use Image::ExifTool;

use dpl::Web::Forum::Processor::Base;
use vars qw(@ISA);
@ISA = qw(dpl::Web::Forum::Processor::Base);


sub ParseFileName {
  my $file = shift;
  $file=~s/^.*[\/\\]//g;
  $file=~s/[^a-z_0-9\-\.]/_/ig;
  my $ext=lc($file);
  $ext=~s/^.+\./$1/g;
  my $name = $file;
  $name=~s/\..*//;
  $name='noname' unless $name;
  return {name=>$name,
          ext=>$ext};
}

sub CheckFileName {
  my $fn = shift;
  my $c=0;
  my $filename=$fn->{name};
  while (db('banner')->SelectAndFetchOne('banner','*',{file=>"$filename.$fn->{ext}"})) {
    $c++;
     $filename=$fn->{name}.$c;
  }
  return $filename;
}


sub ACTION_upload {
  my $self = shift;
  my $file = $self->param('file');
  my $fn = ParseFileName($file);
  my $filename = CheckFileName($fn);
  my $dir = directory('pic').'banners/';
  my $srcfile = $self->LoadFile('file',$dir,"$filename.$fn->{ext}");
#  $self->Mirror("pic/banners/");
  my $comment=$self->param('comment');
  my $link=$self->param('link');

  my ($w,$h);
  if ($fn->{ext} eq 'swf') {
    my $info = Image::ExifTool::ImageInfo($srcfile);
    ($w,$h) = ($info->{ImageWidth},$info->{ImageHeight});
    #     ($w,$h)=($filename=~/(\d+)x(\d+)/);
     ($w,$h)=(580,80)
       unless $w && $h;
  } elsif (my $gd = GD::Image->new($srcfile)) {
    ($w,$h) = $gd->getBounds();
  } else {
    fatal("Unknown file format $fn->{ext} ($srcfile)");
  }
  my @s = stat($srcfile);
  my %h=(
         file=>"$filename.$fn->{ext}",
         size=>$s[7],
         comment=>"$comment",
         link=>"$link",
         width=>$w, height=>$h,
        );
  $self->{banners}->CreateBanner(\%h);
  return '/banners/';
}

# sub init {
#   my $self = shift;
#   $self=$self->SUPER::init(@_);
#   setContext('positions',
#              $self->{pos}={top=>'верх',
#                            bottom=>'низ',
#                            middle=>'середина',
#                            left01=>'лево01',
#                            left02=>'лево02',
#                            left03=>'лево03',
#                            left04=>'лево04',
#                            left05=>'лево05',
#                            left06=>'лево06',
#                            left07=>'лево07',
#                            left08=>'лево08',
#                            left09=>'лево09',
#                            left10=>'лево10',
#                            left11=>'лево11',
#                            left12=>'лево12'
#                           });
#   return $self;
# }

sub ACTION_view {
  my $self = shift;
  my $id = $self->param('id');
  my $banner = $self->{banners}->GetBanner($id);
  $banner->{log} = $self->{banners}->GetDisplayLog($id);
  setContext('posible',[$self->{banners}->ListPositions()]);
  setContext('report',$self->param('report'));
  #setting('uri')->{mirror}.
  $banner->{user}=db()->SuperSelectAndFetch('select * from fuser where id=?',$banner->{user_id})
    if $banner->{user_id};
  $banner->{uri}='/pic/banners/'.$banner->{file};
  return $banner;
}

sub ACTION_del {
  my $self = shift;
  $self->{banners}->DeleteBanner($self->param('id'));
  return '/banners/';
}

sub ACTION_activate {
  my $self = shift;
  my $id = $self->param('id');
  $self->{banners}->ActivateDisplay($id,
                                    $self->param('position'),
                                    dpl::DataType::DateObject::ParseDate($self->param('date_to')));
  return "/banners/view?id=$id";
}

sub ACTION_deactivate {
  my $self = shift;
  my $banner_id = $self->param('banner_id');
  if ($banner_id) {
    $self->{banners}->DeactivateBanner($banner_id);
  } else {
    $banner_id = $self->{banners}->DeactivateDisplay($self->param('id'));
  }
  return "/banners/view?id=$banner_id";
}

sub ACTION_default {
  my $self = shift;
  my $vars = $self->{banners}->ListVarieties();
  foreach my $v (@$vars) {
    $v->{list} = $self->{banners}->ListBanners($v);
  }
  my $hp = $self->{banners}->ListActivePositions();
  my @pos;
  foreach ($self->{banners}->ListPositions()) {
    $_->{banners}=$hp->{$_->{name}};
    push @pos,$_;
  }
  return {vars=>$vars,
          pos=>\@pos};
}

1;
