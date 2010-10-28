#!/usr/bin/perl
use strict;
use lib qw(/home/danil/projects/el/);
use el::Db;
use GD;
use Config::General;
use Number::Format qw(:subs);

#$el::Db::DEBUG=1;
$|=1;

my %config = ParseConfig('./convert.conf');

my $db = el::Db->new($config{database2});

$db->sqlConnect() || die "Can't connect";

# переименовывать русские буквы
# photo max 600x450 - 500

sub get_source {
  my $file = shift;
  my $srcfile = $file;
  $srcfile=~s/\.(.+)$/-src.$1/;
  $srcfile=$file unless -f $srcfile;
  return undef unless -f $srcfile;
  return $srcfile;
}

my $sth = $db->sqlQuery('select * from images order by id');
my $c = 0;
while (my $u = $sth->fetchrow_hashref()) {
  if ($c++>100) { print "."; $c=0; }
  my $dir = "/home/danil/projects/zhazhda/pic/topics/$u->{topic_id}/";
  my $file = "$dir$u->{name}";
  my $srcfile = get_source($file) || die "no file $u->{id} $file";
  next;
  $srcfile=MoveSource($srcfile);
  my $src = GD::Image->new($srcfile);
  unless ($src) {
    print STDERR "Error open file: $u->{id}:$srcfile\n";
#    $db->sqlQuery('delete from images where id=?',$u->{id});
    next;
  }
  next;

  ResampleImage($src,130,250,'t');
  ResampleImage($src,600,450,'');

  my ($w, $h) = $src->getBounds();
  my $nw = 130;
  my $nh = round($h*$nw/$w,0);
  my $new = new GD::Image($nw,$nh,1);
  $new->copyResampled($src,0,0,0,0,$nw,$nh,$w,$h);

  my $t = $u->{name};
  $t=~s/\.(.*)//;
  $t="image$u->{id}" unless $t;
  my $newfile;
  if ($1 eq 'gif') {
    $newfile = "$t-t.gif";
    open (FILE,"> $dir$newfile") || die("Не могу сохранить снимок в файл $dir$newfile");
    binmode FILE;
    print FILE $new->gif();
    close FILE;
  } else {
    $newfile = "$t-t.jpg";
    open (FILE,"> $dir$newfile") || die("Не могу сохранить снимок в файл $dir$newfile");
    binmode FILE;
    print FILE $new->jpeg(80);
    close FILE;
  }
  print "$nw,$nh\t$u->{topic_id}/$u->{id}/$newfile \n";
  $db->sqlQuery('update images set t_name=?, twidth=?, theight=? where id=?',
                $newfile,$nw,$nh,$u->{id});
  $db->sqlCommit();
}

# my $sth = $db->sqlQuery('select * from gallery where twidth!=130 order by image_id');
# my $c = 0;
# while (my $u = $sth->fetchrow_hashref()) {
#   my $res = $db->sqlSelectOne('select * from images where id=?',$u->{image_id});
#   unless ($res) {
#     print STDERR "No such image: $u->{image_id} from gallery\n";
#     next;
#   }
#   print "$u->{image_id}: $u->{t_name} -> $res->{t_name} $u->{twidth} -> $res->{twidth}\n";
#   $db->sqlQuery('update gallery set t_name=?, twidth=?, theight=? where image_id=?',
#                 $res->{t_name},$res->{twidth},$res->{theight},$u->{image_id});
# }
# $db->sqlCommit();


$db->sqlCommit();
print "\n";
