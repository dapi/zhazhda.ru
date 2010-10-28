#!/usr/bin/perl
use strict;
use lib qw(/home/danil/projects/el/);
use el::Db;
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

my $db_new = el::Db->new($config{database});
my $db_old = el::Db->new($config{database2});

$db_new->sqlConnect() || die "Can't connect";
$db_old->sqlConnect() || die "Can't connect";

print "delete: ";
if (1) {
print " user";
$db_new->sqlQuery('truncate table place, fuser cascade');
$db_new->sqlCommit();

print ", insert";
$db_new->sqlQuery("insert into fuser values (10000,current_timestamp,'zadmin','zadmin','admin','admin\@orionet.ru',NULL,'127.0.0.1','127.0.0.1',current_timestamp,'1',now(),1,'t');");
$db_new->sqlQuery("insert into fuser values (20000,current_timestamp,'ztest','ztest','test','test\@orionet.ru',NULL,'127.0.0.1','127.0.0.1',current_timestamp,'2',now(),1);");
$db_new->sqlCommit();




#$db_new->sqlQuery('truncate table comment');

#print "files";
#$db_new->sqlQuery('truncate table filesholder_file cascade');

#print ", dirs ";
#$db_new->sqlQuery('truncate table filesholder_dir cascade');
print ", filesholder";
$db_new->sqlQuery("
insert into filesholder_dir values (1,10000,'files/','Просто файлы','f');
insert into filesholder_dir values (2,10000,'gallery/','Галлерея','Галлерая фото',NULL,'t');
insert into filesholder_dir values (3,10000,'gallery/random/','Текущие случайные снимки','Галлерая случайных фото',2);
insert into filesholder_dir values (4,10000,'files/commerce/','Коммерческие материалы','',1);
insert into filesholder_dir values (5,10000,'files/brand/','Фирменный стиль','',1);
insert into filesholder_dir values (6,10000,'journal/','Каталоги журналов','f');
insert into filesholder_dir values (7,10000,'journal/zhazhda/','Файлы журнала Жажда',5);
insert into filesholder_dir values (8,10000,'journal/afisha/','Файлы журнала Афиша',5);
select nextval('filesholder_dir_id_seq') from filesholder_dir;
");

#print ", topic";
#$db_new->sqlQuery('truncate table topic cascade');

#print ", place";
#$db_new->sqlQuery('truncate table place cascade');

#print ", mail_box";
#$db_new->sqlQuery('truncate table mail_box');

#print ", mail";
#$db_new->sqlQuery('truncate table mail cascade');

print ", journal";
$db_new->sqlQuery("
insert into journal
        values (1,current_timestamp,current_timestamp,
        'Жажда Жизни','zhazhda/','Форум промо-группы Жажда Жизни',
        10000,
        1,1,1,1,
        0,0,0,
        NULL,NULL,1,'t',
        't','juice/top.jpg','juice/medium.jpg','juice/bottom.jpg','#e1e0e0','black');

insert into journal
        values (2,current_timestamp,current_timestamp,
        'Афиша','afisha/','Афиша, анонсы.',
        10000,
        1,1,1,1,
        0,0,0,
        NULL,NULL,2,'t',
        't','cola/top.jpg','cola/medium.jpg','cola/bottom.jpg','black','white',
        'afisha','nz::Object::Journal::Afisha','afisha');

insert into journal
        values (3,current_timestamp,current_timestamp,
        'Музыка','music/','',
        10000,
        1,1,1,1,
        0,0,0,
        NULL,NULL,3,'t',
        't','cola/top.jpg','cola/medium.jpg','cola/bottom.jpg','black','white');

insert into journal
        values (4,current_timestamp,current_timestamp,
        'Коммуналка','komunalka/','Наша коммунальная квартира',
        10000,
        1,1,1,1,
        0,0,0,
        NULL,NULL,4,'t',
        't','journal/top.jpg','journal/medium.jpg','journal/bottom.jpg','#fdc000','white');

insert into journal
        values (5,current_timestamp,current_timestamp,
        'DESIGN','design/','Дизайн',
        10000,
        1,1,1,1,
        0,0,0,
        NULL,NULL,5,'f',
        't','journal/top.jpg','journal/medium.jpg',NULL,'#fdc000','white');

insert into journal
        values (6,current_timestamp,current_timestamp,
        'Matrix Game','matrix/','Ночная игра Матрикс',
        10000,
        1,1,1,1,
        0,0,0,
        NULL,NULL,6,'f',
        't','journal/top.jpg','journal/medium.jpg',NULL,'#fdc000','white');

insert into journal
        values (7,current_timestamp,current_timestamp,
        'Другой спорт','drugoi/','Другой спорт',
        10000,
        1,1,1,1,
        0,0,0,
        NULL,NULL,7,'f',
        't','journal/top.jpg','journal/medium.jpg',NULL,'#fdc000','white');

select nextval('journal_id_seq') from journal;
");
$db_new->sqlCommit();


print "ok\n\n";
users();
places();
topics_and_comments();
#topic_views();
#mails();mail_boxes();
}
$db_new->sqlQuery('delete from filesholder_file');
media();

$db_new->sqlCommit();
exit;
foreach (qw(zabor zabor_view sign_code black_list topic_vote topic_to_print auction auction_steps)) {
  copy_table($_);
}



print "\n";

#
# my $sth = $db_old->sqlQuery('select * from gallery');
# while (my $g = $sth->fetchrow_hashref()) {
#   my $image = $db_old->sqlSelect('select * from images where id=?',$g->{image_id});
#
#   $db_new->sqlInsert({id=>$g->});
#   push @list,$_;
# }

$db_new->sqlCommit();



sub copy_table {
  my $table = shift;
  print "$table: ";
  my $sth = $db_old->sqlQuery("select * from $table");
  my $c = 0;
  #  $db_new->sqlQuery("truncate table $table");
  $db_new->sqlQuery("delete table $table");
  while (my $u = $sth->fetchrow_hashref()) {
    next if $table eq 'zabor_view' && ($u->{zabor_id}==1 || $u->{zabor_id}==31 || $u->{zabor_id}==118 || $u->{zabor_id}==70);
    print ".";
    $db_new->sqlInsert($table,$u);
  }
  $db_new->sqlCommit();
  print "\n";
}


sub get_size {
  my $f = shift;
  my $size = (stat($f))[7];
  print STDERR "No file $f\n" unless $size;
  return $size || 0;
}

sub media {
#  $db_new->sqlQuery('truncate table filesholder_file cascade');
  my %topics;
  my $sth = $db_old->sqlQuery('select * from topic');
  while (my $u = $sth->fetchrow_hashref()) {
    $topics{$u->{id}}=$u;
  }
  print '+';

  $db_new->sqlQuery('update filesholder_dir set files=0');
  print "images: ";
  my %dirs;
  my $sth = $db_new->sqlQuery('select * from filesholder_dir');
  while (my $u = $sth->fetchrow_hashref()) {
    next unless $u->{topic_id};
    $dirs{$u->{topic_id}}=$u->{id};
  }
  my $sth = $db_old->sqlQuery('select * from images');
  my $c = 0;
  # last_comment_id
  my %files;
  my %files_count;

  while (my $u = $sth->fetchrow_hashref()) {
    if ($c++>100) { print "."; $c=0;  $db_new->sqlCommit(); }
#    print "topic_id: $u->{topic_id}\n";
    my $dir_id=$dirs{$u->{topic_id}};
    unless ($dir_id) {
#      die $u->{topic_id};
      my $t = $db_new->sqlSelectOne('select * from topic where id=?',$u->{topic_id});
      unless ($t) {
        print STDERR "no such topic $u->{topic_id}\n";
        next;
      }
      $dir_id = CreateTopicDir($t);

      $dirs{$u->{topic_id}} = $dir_id;
    }

    my $src = $u->{name};
    $src=~s/\.(.+)$/-src.$1/;
    $files_count{$dir_id}++;
    my $src_file = "/home/danil/projects/zhazhda/pic/topics/$u->{topic_id}/$src";
    my $thumb_file = "/home/danil/projects/zhazhda/pic/topics/$u->{topic_id}/$u->{t_name}";

    $src_file=~s/-src// unless -f $src_file;
#       if ($file->{media_width}>600) {
#     $file->{media_height}=$file->{media_height}*600/$file->{media_width}; $file->{media_width}=600;
#   }
#   if ($file->{media_height}>450) {
#     $file->{media_width}=$file->{media_width}*450/$file->{media_height}; $file->{media_height}=450;
#   }

    my $w = $u->{twidth}/2; $w=~s/\..+//;
    my $h = $u->{theight}/2; $h=~s/\..+//;
    my %h=(dir_id=>$dir_id,
           id=>$u->{id},
           topic_id=>$u->{topic_id},
           path=>"topics/$u->{topic_id}/",
           name=>$u->{name},
           file=>$u->{name},
           src_file=>$src,
           src_size=>get_size($src_file),

           user_id=>$u->{user_id} || 1,

           type=>'image',

           thumb_width=>$w,
           thumb_height=>$h,
           thumb_file=>$u->{t_name},
           thumb_size=>get_size($thumb_file),

           gallery_width=>$u->{twidth},
           gallery_height=>$u->{theight},
           gallery_file=>$u->{t_name},
           gallery_size=>get_size($thumb_file),

           media_width=>$u->{width},
           media_height=>$u->{height},

           downloads=>$u->{counter},
           views=>$u->{counter},
           title=>$u->{comment},
           comment=>$u->{comment},
           is_moderated=>$u->{is_gallery_processed},
           topic_subject=>$topics{$u->{topic_id}}->{subject}
          );
    $files{$u->{id}}=\%h;
    $db_new->sqlInsert('filesholder_file',\%h);
  }
  $db_new->sqlCommit();
  print "\n";


#  $el::Db::DEBUG=1;
  print "gallery: ";
  my $m = $db_new->sqlSelectOne("select max(id) as id from filesholder_file");
  $db_new->sqlQuery("select setval('filesholder_file_id_seq',$m->{id})");
  $c=0;

  my $sth = $db_old->sqlQuery('select * from gallery');

  while (my $u = $sth->fetchrow_hashref()) {
    my $h = $files{$u->{image_id}};#$db_new->sqlSelectOne("select * from filesholder_file where id=?",$u->{image_id});
    unless ($h) {
      print STDERR "Нет такого изображения $u->{image_id}\n";
      next;
    }
    if ($c++>100) { print "."; $c=0;  $db_new->sqlCommit(); }
    $h->{dir_id}=$GALLERY_DIR_ID;
    $files_count{$GALLERY_DIR_ID}++;
    $h->{link_id}=$h->{id};
    delete $h->{id};
    my $linked_id = $db_new->sqlInsert('filesholder_file',$h,'id');
    $db_new->
      sqlQuery("update filesholder_file set linked=?, is_in_gallery='t' where id=?",
               $linked_id,$h->{link_id});
  }
  print "\n";

  print "music: ";
  $sth = $db_old->sqlQuery('select * from music');
  $c = 0;
  # last_comment_id

  while (my $u = $sth->fetchrow_hashref()) {
    if ($c++>100) { print "."; $c=0;  $db_new->sqlCommit(); }
#    print "topic_id: $u->{topic_id}\n";
    my $dir_id=$dirs{$u->{topic_id}};
    unless ($dir_id) {
#      die $u->{topic_id};
      my $t = $db_new->sqlSelectOne('select * from topic where id=?',$u->{topic_id});
      unless ($t) {
        print STDERR "no such topic $u->{topic_id}\n";
        next;
      }
      $dir_id = CreateTopicDir($t);

      $dirs{$u->{topic_id}} = $dir_id;
    }
    my $src = $u->{name};
    $files_count{$dir_id}++;
    my $t = $u->{title} || $u->{comment};
    $db_new->
      sqlInsert('filesholder_file',
                {dir_id=>$dir_id,
                 topic_id=>$u->{topic_id},
                 path=>"topics/$u->{topic_id}/",
                 name=>"$u->{m_name}.$u->{m_ext}",
                 file=>"$u->{m_name}.$u->{m_ext}",
                 src_file=>"$u->{m_name}.$u->{m_ext}",
                 user_id=>$u->{user_id} || 1,

                 type=>'music',

                 length_secs=>$u->{total_secs_int},
                 title=>$t,

                 media_track=>$u->{track},
                 media_artist=>$u->{artist},
                 media_album=>$u->{album},
                 media_year=>$u->{year},
                 media_genre=>$u->{genre},

                 downloads=>$u->{counter},
                 views=>$u->{counter},
                 size=>$u->{size},

                 comment=>$u->{comment},
                 topic_subject=>$topics{$u->{topic_id}}->{subject}
                },'id');

  }
  $db_new->sqlCommit();
  print "\n";

    print "movies: ";
  $sth = $db_old->sqlQuery('select * from movies');
  $c = 0;
  # last_comment_id

  while (my $u = $sth->fetchrow_hashref()) {
    if ($c++>100) { print "."; $c=0;  $db_new->sqlCommit(); }
#    print "topic_id: $u->{topic_id}\n";
    my $dir_id=$dirs{$u->{topic_id}};
    unless ($dir_id) {
#      die $u->{topic_id};
      my $t = $db_new->sqlSelectOne('select * from topic where id=?',$u->{topic_id});
      unless ($t) {
        print STDERR "no such topic $u->{topic_id}\n";
        next;
      }
      $dir_id = CreateTopicDir($t);

      $dirs{$u->{topic_id}} = $dir_id;
    }
    my $src = $u->{name};
    $files_count{$dir_id}++;
    $db_new->
      sqlInsert('filesholder_file',
                {dir_id=>$dir_id,
                 topic_id=>$u->{topic_id},
                 path=>"topics/$u->{topic_id}/",
                 name=>"$u->{m_name}.$u->{m_ext}",
                 file=>"$u->{m_name}.$u->{m_ext}",
                 src_file=>"$u->{m_name}.$u->{m_ext}",
                 user_id=>$u->{user_id} || 1,

                 type=>'movie',

                 media_width=>$u->{mwidth},
                 media_height=>$u->{mheight},

                 downloads=>$u->{counter},
                 views=>$u->{counter},
                 size=>$u->{size},

                 title=>$u->{comment} || $u->{m_name},
                 comment=>$u->{comment},
                 topic_subject=>$topics{$u->{topic_id}}->{subject}
                },'id');

  }
  $db_new->sqlCommit();
  print "\n";


  print "files count: ";
  foreach (keys %files_count) {
    $db_new->sqlQuery('update filesholder_dir set files = files + ? where id=?',$files_count{$_},$_);
  }
  print "\n";
  $db_new->sqlCommit();

  print "persons: ";
  $sth = $db_old->sqlQuery('select * from images_persons');
  $c = 0;
  # last_comment_id
#  $db_new->sqlQuery('delete form files_persons');
  while (my $u = $sth->fetchrow_hashref()) {
    if ($c++>100) { print "."; $c=0;  $db_new->sqlCommit(); }
    $u->{file_id}=$u->{image_id}; #$files{$u->{image_id}};
    delete $u->{image_id};
    $db_new->
      sqlInsert('files_persons',$u);

  }
  $db_new->sqlCommit();
  print "\n";
}


sub topic_views {
  print "topic_views: ";
  my %topics;
  my $sth = $db_old->sqlQuery('select * from topic');
  while (my $u = $sth->fetchrow_hashref()) {
    $topics{$u->{id}}=$u;
  }
  print '+';
  my $sth = $db_old->sqlQuery('select * from topic_visit');
  my $c = 0;
  # last_comment_id
  my %tv;
  while (my $u = $sth->fetchrow_hashref()) {
    if ($c++>1000) { print "."; $c=0;  $db_new->sqlCommit(); }
    my $nc;
    my $key = "$u->{topic_id}-$u->{message_id}";
    if ($topics{$u->{topic_id}}->{last_comment_id}<=$u->{message_id}) {
      $nc = 0;
    } elsif (exists $tv{$key}) {
      $nc = $tv{$key};
    } else {
      $nc=
        $db_new->
          sqlSelectOne('select count(*) as count from comment where topic_id=? and id>?',
                       $u->{topic_id},
                       $u->{message_id} || 0
                      )->{count};
      $tv{$key}=$nc;

    }
    $db_new->sqlInsert('topic_views',
                       {topic_id=>$u->{topic_id},
                        user_id=>$u->{user_id},
                        last_comment_id=>$u->{message_id},
                        last_view_time=>$u->{lastvisit},
                        new_comments=>$nc,
                        answers=>$u->{has_answers},
                        new_answers=>$u->{answers},
                        is_subscribed=>$u->{is_subscribed},
                        is_hidden=>$u->{is_hide},
                        vote_id=>$u->{vote_id},
                       });
  }
  $db_new->sqlCommit();
  print "\n";
}

sub mails {
  my $self = shift;
  print "mails: ";
  my $sth = $db_old->sqlQuery('select * from mails order by id');
  my $c = 0;
  while (my $u = $sth->fetchrow_hashref()) {
    if ($c++>1000) { print "."; $c=0; }
    $u->{message}=$u->{text};
    delete $u->{text};
    $db_new->sqlInsert('mail',$u);
  }
  $db_new->sqlQuery("select nextval('mail_id_seq') from mail");
  $db_new->sqlCommit();
  print "\n";
}

sub mail_boxes {
  print "mail boxes (inbox): ";
  my $sth = $db_new->sqlQuery('select max(createtime) as last_incoming, count(*) as count, user_id, talker_id from mail where is_inbox group by user_id, talker_id');
  my $c = 0;
  while (my $u = $sth->fetchrow_hashref()) {
    if ($c++>100) { print "."; $c=0; }
    $db_new->sqlInsert('mail_box',{user_id=>$u->{user_id},
                                   talker_id=>$u->{talker_id},
                                   incomings=>$u->{count},
                                   last_incoming=>$u->{last_incoming}});
  }
  $db_new->sqlCommit();
  print "\n";

  print "mail boxes (outbox): ";
  my $sth = $db_new->sqlQuery('select max(createtime) as last_view, count(*) as count, user_id, talker_id from mail where not is_inbox group by user_id, talker_id');
  my $c = 0;
  while (my $u = $sth->fetchrow_hashref()) {
    if ($c++>100) { print "."; $c=0; }
    $db_new->sqlQuery('update mail_box set outcomings=?, last_view=? where user_id=? and talker_id=?',
                      $u->{count},
                      $u->{last_view},
                      $u->{user_id},$u->{talker_id});
  }
  $db_new->sqlCommit();
  print "\n";


  print "mail boxes (new mails): ";
  my $sth = $db_new->sqlQuery('select count(*) as new_mail, user_id, talker_id from mail where is_inbox and not is_shown group by user_id, talker_id');
  while (my $u = $sth->fetchrow_hashref()) {
    print '.';
    $db_new->sqlQuery('update mail_box set new_mail=? where user_id=? and talker_id=?',
                      $u->{new_mail},
                      $u->{user_id},
                      $u->{talker_id});
  }
  $db_new->sqlCommit();
  print "\n";

}


sub CreateTopicDir {
  my ($h) = @_;
  #  my $link = $h->{journal_id}==1 ? 'zhazhda' : 'afisha';
  my $parent_id = $h->{journal_id}+$PLUS_DIR_ID;
  die "error 3 ",join(',',%$h)," (parent_id:$parent_id)" if $parent_id<=5;
  $db_new->sqlQuery('update filesholder_dir set subdirs = subdirs + 1 where id=?',$parent_id);
#  print STDERR "Create topic $h->{id}, $parent_id\n";
  return
    $db_new->
      sqlInsert('filesholder_dir',
                {parent_id=>$parent_id,
                 path=>"topics/$h->{id}/",
                 name=>"$h->{id}:$h->{subject}",
                 user_id=>$h->{user_id} || 1,
                 topic_id=>$h->{id},
                },'id');
}


sub places {
  print "place: ";
  my $sth = $db_old->sqlQuery('select * from place order by id');
  my $max=0;
  while (my $u = $sth->fetchrow_hashref()) {
    print ".";
    my $p = $db_new->sqlSelectOne('select * from place2 where id=?',$u->{id});
    my %h = (map {$_=>$u->{$_}} qw(id city_id address name comment));
    $h{user_id}=1;
    $h{is_moderated}=0;
    $h{category_id}=1;
    if ($p) {
      map {$h{$_}=$p->{$_}} qw(name address category_id is_moderated is_removed);
    }
    $db_new->sqlInsert('place',\%h);
    $max=$u->{id} if $max<$u->{id};
  }
  $db_new->sqlQuery("select setval('place_id_seq',?)",$max+1);
  print "\n\n";
  $db_new->sqlCommit();
}


sub users {
  print "fuser: ";
  my $sth = $db_old->sqlQuery('select * from zuser order by id');
  my $c=0;
  while (my $u = $sth->fetchrow_hashref()) {
    if ($c++>100) { print "."; $c=0; }
    my %h = (map {$_=>$u->{$_}} qw(id login password name email level phone last_ip session sessiontime lasttime is_admin is_academic hide_mat is_removed remove_comment is_logged image_time));

    my %f = (sign_ip=>'ip',
             topics=>'topic_count',
             comments=>'comment_count',
             timestamp=>'createtime',
             image_width=>'image_src_width',
             image_height=>'image_src_height',
             thumb_width=>'image_width',
             thumb_height=>'image_height',
             thumb_time=>'image_time',
            );

    map {$h{$_}=>$u->{$f{$_}}} keys %f;
    $h{session} = "ses$h{id}";
    $h{city_id} = 1;
    $h{sign_ip}='127.0.0.1' unless $h{sign_ip};
    $h{last_ip}=$h{sign_ip} unless $h{last_ip};
    $h{image_file}="users/$u->{id}-src.$u->{image_ext}";
    $h{thumb_file}="users/$u->{id}.$u->{image_ext}";
    $db_new->sqlInsert('fuser',\%h);
  }
  $db_new->sqlQuery("select nextval('fuser_id_seq') from fuser");
  print "\n\n";
  $db_new->sqlCommit();
}



sub topics_and_comments {
  print "topic: ";
  my $c = 0;
  my %topics;
  my %places;
  my %places_id;
  my $sth = $db_new->sqlQuery('select * from place');
  while (my $p = $sth->fetchrow_hashref()) {
    $places{$p->{name}}=$p->{id};
    $places_id{$p->{id}}=$p;
  }

  $sth = $db_old->sqlQuery('select * from topic order by id');
  #$el::Db::DEBUG=1;
  while (my $u = $sth->fetchrow_hashref()) {
    #$el::Db::DEBUG=1 if $u->{id}==1360;
    # if $u->{id}==1360;
#    print "$u->{id}\n";
    if ($c++>100) { print "."; $c=0; $db_new->sqlCommit(); }
    my %h = (map {$_=>$u->{$_}} qw(id is_removed subject text user_id is_bold is_red));
    $u->{ip}='127.0.0.1' unless $u->{ip};
    $h{gallery_type}=3 if $u->{is_gallery};
    $h{gallery_type}=1 if $u->{topic_id}==8496;
    my %f = (create_ip=>'ip',
             change_ip=>'ip',
             show_counter=>'counter',
             last_comment_id=>'last_message_id',
             create_time=>'createtime',
             change_time=>'lasttime',
             subscribers=>'subscribers_count',

             images=>'images_count',
             movies=>'movies_count',
             music=>'music_count',

             comments=>'comments_count',
            );
    $h{journal_id}=1;
    if ($u->{is_vote}) {
      $h{topic_type}='vote';
      $h{vote_active}=$u->{vote_finished} ? 'f' : 't';
      $h{vote_access}=$u->{show_vote}*2;
    } elsif ($u->{is_auction}) {
      $h{topic_type}='auction';
    } elsif ($u->{event_id}) {

      my $event = $db_old->sqlSelectOne('select * from event where id=?',$u->{event_id});

      if ($event->{date_start}) {
#        $h{journal_id}=2;
        $h{event_date} = $event->{date_start};
        $h{category_id}=1;
        $h{event_time} = $event->{time_start};
        if ($event->{place_id}) {
          $h{place_id} = $event->{place_id};
        } elsif ($h{place_id} = $places{$event->{place_other}}) {
        } elsif ($event->{place_other}) {
#          print "new: $event->{place_other}\n";
          $h{place_id} = $db_new->
              sqlInsert('place',
                        {city_id=>1,
                         user_id=>$h{user_id},
                         category_id=>1,
                         is_moderated=>'t',
                         name=>$event->{place_other},
                         address=>$event->{place_other}},
                        'id');
          $places{$event->{place_other}}=$h{place_id};
          $places_id{$h{place_id}}=$event->{place_other};
        }
      }
#      unless (exists $places_id{$h{place_id}}) {
#        print " $h{place_id} ";
#        $h{place_id}=undef;
#        next;
#      }

    }
    map {$h{$_}=$u->{$f{$_}}} keys %f;
    #  print "topic_id: $h{id}\n";
    #  die join(',',%h) if $h{id}==6;
    $h{dir_id}=CreateTopicDir(\%h)
      if $h{images} || $h{music} || $h{movies};
    $topics{$h{id}}=\%h;
    $db_new->sqlInsert('topic',\%h);
    if ($u->{is_hot}) {
      $db_new->sqlInsert('journal_topic_hot',{journal_id=>$h{journal_id},
                                          topic_id=>$h{id},
                                          is_owner=>'t',
                                          is_removed=>$h{is_removed}});
    } else {
      $db_new->sqlInsert('journal_topic',{journal_id=>$h{journal_id},
                                          topic_id=>$h{id},
                                          is_owner=>'t',
                                          is_removed=>$h{is_removed}});
    }
  }

  $db_new->sqlQuery("select nextval('topic_id_seq') from topic");
  $db_new->sqlCommit();
  print "\n";

  print "comments: ";

#   my $sth = $db_old->sqlQuery('select * from topic');
#   while (my $u = $sth->fetchrow_hashref()) {
#     $topics{$u->{id}}=$u;
#   }
#  print '+';
  my $sth = $db_old->sqlQuery('select * from message order by id');
  my $c=0;
  my $max;
  while (my $u = $sth->fetchrow_hashref()) {
    $max=$u->{id} if $u->{id}>$max;
    unless ($topics{$u->{topic_id}}) {
      print STDERR "Нет такого топика $u->{topic_id}\n";
      next;
    }

    if ($c++>100) { print "."; $c=0; }
    my $parent_user_id = $u->{parent_user_id};
    $parent_user_id = $topics{$u->{topic_id}}->{user_id}
      unless $parent_user_id;
    $db_new->sqlInsert('comment',
                       {id=>$u->{id},
                        create_ip=>$u->{ip} || '127.0.0.1',
                        change_ip=>$u->{ip},
                        create_time=>$u->{create_time} || '2005-01-01',
                        change_time=>$u->{change_time} || '2005-01-01',
                        topic_id=>$u->{topic_id},
                        parent_user_id=>$parent_user_id,
                        user_id=>$u->{user_id},
                        text=>$u->{text},
                        parent_id=>$u->{parent_id}
                       });
  }
  $db_new->sqlQuery("select setval('comment_id_seq',?) from comment",$max+1);
  print "\n\n";
  $db_new->sqlCommit();
}
