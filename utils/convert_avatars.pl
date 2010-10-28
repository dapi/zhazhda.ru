#!/usr/bin/perl
use strict;
use lib qw(/home/danil/projects/el/);
use el::Db;
use GD;
use Config::General;
use Getopt::Compact;
use UNIVERSAL qw(isa);

my $o = new Getopt::Compact
  (#modes => [qw(debug)],
   usage=>1,
   struct =>
   [
    [[qw(d debug)], "SQL DEBUG MODE",'',\$el::Db::DEBUG],
   ]
  )->opts();

#$el::Db::DEBUG=$opts->{debug};

$|=1;



my %config = ParseConfig('./convert.conf');

my $GALLERY_DIR_ID=2;
my $PLUS_DIR_ID=5;

my $db = el::Db->new($config{database});
my $db_old = el::Db->new($config{database2});

$db->sqlConnect() || die "Can't connect";
$db_old->sqlConnect() || die "Can't connect";
if (0) {
  print "createtime ";
  my $sth = $db_old->sqlQuery('select * from zuser order by id');
  while (my $u = $sth->fetchrow_hashref()) {
    print "$u->{id} $u->{createtime}\n";
    $db->sqlQuery(qq(update fuser set timestamp=?, sign_ip=? where id=?),
                  $u->{createtime},$u->{ip},$u->{id});
  $db->sqlCommit();
  }
exit 1;
}
print "avatars: ";
my $sth = $db->sqlQuery('select * from fuser order by id');
my $c=0;
my %e;
while (my $u = $sth->fetchrow_hashref()) {

  my ($src_file,$src_w,$src_h)=getsize("$u->{id}-src");
  my ($t_file,$t_w,$t_h)=getsize("$u->{id}");
  print "$u->{id} $t_file ($t_w,$t_h)\n";
   $db->sqlQuery(qq(update fuser set
 image_time=now(), image_file=?, image_width=?, image_height=?,
 thumb_time=now(), thumb_file=?, thumb_width=?, thumb_height=? where id=?),
                 $src_file || '', $src_w || 0, $src_h || 0,
                 $t_file || '', $t_w || 0, $t_h || 0,
                 $u->{id});
}
$db->sqlCommit();


sub getsize {
  my $file = shift;
  my $dir = '/usr/local/nginx/www/mirror/zhazhda/pic/users';

  my $f = -f "$dir/$file.gif" ? "$file.gif" : "";
  $f = "$file.jpg" if -f "$dir/$file.jpg";
  $f = "$file.jpeg" if -f "$dir/$file.jpeg";
  $f = "$file.png" if  -f "$dir/$file.png";
  my $src = GD::Image->new("$dir/$f") || return undef;;
  my ($w,$h) = $src->getBounds();
  return ($f,$w,$h);

}
