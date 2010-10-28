package nz::Home;
use strict;
use Exporter;
use dpl::Web::Forum;
use dpl::Context;
use dpl::Db::Filter;
use dpl::Web::Forum::Journal;
use dpl::Error;
use dpl::Db::Database;
use dpl::Db::Table;
use URI::Escape;
use URI::Split  qw(uri_split uri_join);
use JSON::XS;
use Encode;
use dpl::System;
use nz::Utils;

use dpl::Web::Forum::Processor::Base;
use vars qw(@ISA);
@ISA = qw(dpl::Web::Forum::Processor::Base);

sub ACTION_sub {
  my $self = shift;
  
}


sub ACTION_json_get_topic {
  my $self = shift;
  my $id = $self->param('id');
  my $topic = el::Db::db()->sqlSelect('select * from topic where id=?',$id)
    || return undef;
  $topic->{comments} = el::Db::db()->sqlSelectAll('select * from comment where topic_id=? order by id',$id);
  my $j = JSON::XS->new();
  my $a = $j->encode($topic);
  my @a = Encode::from_to($a,'koi8-r','utf8');
  return $a;
}

sub ACTION_afisha_fake {
  my $self = shift;
  my $j = forum()->
    JournalInstance(2);
  return {topics=>$j->ListTopics({#where=>["event_date>=now()"],
                                  #                                  use_filter=>1,
                                  #sort_result=>1
                                 })
         };
}

sub ACTION_events_atom {
  my $self = shift;

  my $j = dpl::Web::Forum::Journal::JournalInstance(2);
  my $today = filter('date')->ToSQL(today());
  my @where;
  my @bind;
  
  push @where, "event_date>=?";
  push @bind, $today;
  
  return  {journal=>$j->Get(),
  	       link=>setting('uri')->{home}.'events.atom',
           topics=>$j->ListTopics({where=>\@where,
                                   bind=>\@bind,
                                   order=>'id desc',
                                  }),
            cats=>table('place_category')->HashList()
          };
}

sub ACTION_edit_user {
  my $self = shift;
  return undef
    unless
      $self->CheckReferer('Вы действительно желаете отредактировать пользователя?');

  my $id = $self->param('user_id');
  my $t = table('fuser');
  my $user = $t->Load($id);
  fatal("No such user: $id") unless $user;
  my $login = uri_escape($user->{login});
  my %h = map {$_=>$self->param($_)} qw(banners_limit top_limit block_type block_comment domain is_academic);
  delete $h{block_type} if $user->{is_admin};
  $h{banners_limit}+=0;
  $h{top_limit}+=0;
  $h{is_removed}=1 if $h{block_type}==11;
  $t->Modify(\%h);
  return "/user/$login/profile";
}

sub ACTION_stats {
  my $self = shift;
  $self->addNav('stats');
  my $click = db()->SelectAndFetchAll('select sum(counter) as sum, host from click_counter group by host');
  $click = [reverse sort {$a->{sum} <=> $b->{sum}} @$click];
  $click = [splice(@$click,0,10)];
  my $persons = db()->SelectAndFetchAll("select user_id, count(*) as count from files_persons left join fuser on fuser.id=files_persons.user_id group by user_id order by count(*) desc limit 10");
  my $c = db()->SelectAndFetchAll('select user_id, count(*) as count from topic_views where rating<3 group by user_id order by count(*) desc limit 10');
  my $h = db()->SelectAndFetchAll('select user_id, count(*) as count from topic_views where rating>3 group by user_id order by count(*) desc limit 10');
  foreach (@$persons,@$c,@$h) {
    $_->{user} = db()->SelectAndFetchOne("select * from fuser where id=$_->{user_id}");
  }
  my $j = db()->SelectAndFetchOne('select * from journal where id=1');


  return {click=>$click,
	    sms=>db()->SelectAndFetchAll('select sms_event_type, count(*) as count from fuser where sms_event_type>0 group by sms_event_type'),
    
          black=>db()->SelectAndFetchAll('select * from fuser where not is_removed order by blacked desc limit 10'),
          pt=>db()->SelectAndFetchAll('select * from fuser where not is_removed order by topics desc limit 10'),
          pc=>db()->SelectAndFetchAll('select * from fuser where not is_removed order by comments desc limit 10'),

          bt=>db()->SelectAndFetchAll('select * from topic where not is_removed order by views desc limit 10'),

          btr5=>db()->SuperSelectAndFetchAll('select * from topic where not is_removed and raters>? and rating>=3 order by rating desc limit 10',$j->{min_raters}),
        #  btr1=>db()->SuperSelectAndFetchAll('select * from topic where not is_removed and raters>? and rating<3 order by rating desc limit 10',$j->{min_raters}),
          max_raters=>db()->SelectAndFetchAll('select * from topic where not is_removed order by raters desc limit 10'),

          cold_raters=>$c,
          hot_raters=>$h,
          persons=>$persons};
}

sub ACTION_stats_click {
  my $self = shift;
  my $all = db()->SelectAndFetchAll('select sum(counter) as sum, host from click_counter group by host');
  $all = [reverse sort {$a->{sum} <=> $b->{sum}} @$all];
  return {all=>$all};
}


sub ACTION_places {
  my $self = shift;
  my $city_id = $self->param('city');
  $city_id=getUser()->Get('city_id') if !$city_id && getUser();

  #Чебоксары
  $city_id=1 unless $city_id;
  setContext('city',table('city')->Load($city_id));
  my %w=(city_id=>$city_id);
  my $cat = $self->param('cat');
  my $l = table('place_category')->List();
  setContext('categories',$l);

  my %h;
  foreach (@$l) {
    $h{$_->{id}}=$_;
  }
  setContext('categories_h',\%h);
#   if ($cat) {
#     $w{category_id}=$cat;
#     setContext('category',$h{$cat});
#   } else {
#     setContext('category',$h{0});
#   }
  my $places = table('place')->List(\%w);
#   my $all = {id=>0,name=>'Все',
#              id=>'no',name=>'Прочее'};
  #  unshift @$l, $h{0}=$all;
  foreach (@$places) {
    $h{$_->{category_id}}->{places}=[]
      unless $h{$_->{category_id}}->{places};
    push @{$h{$_->{category_id}}->{places}},$_;
  }
  return {places=>$places};
}

sub ACTION_edit_place_form {
  my $self = shift;
  my $id = $self->param('id');

  my $place;
  if ($id) {
    $place = table('place')->Load($id);
  } else {
    $place = {category_id=>$self->param('category_id')};
  }

  setContext('category_list',table('place_category')->List());
  setContext('city_list',table('city')->List());
  setContext('fields',$place);
  return $place;
}

sub ACTION_delete_place {
  my $self = shift;
  my $id = $self->param('id');
  return undef
    unless
      $self->CheckReferer('Вы действительно желаете удалить место?');


  if ($self->param('ok')) {
    my $new = $self->param('new_place_id') || undef;
    db()->Query("update topic set place_id=? where place_id=?", $new,$id);
    table('place')->Delete($id);
    $self->template('redirect');
    return '/places/';
  } else {
    my $place  = table('place')->Load($id);
    my $list= table('place')->List({city_id=>$place->{city_id}});
    unshift @$list,{id=>0,name=>'Нет места'};
    setContext('places',$list);
    return $place;

  }
}


sub ACTION_edit_place {
  my $self = shift;
  return undef
    unless
      $self->CheckReferer('Вы действительно желаете редактировать место?');
  
  my $h = $self->GetParams(qw(name address city_id category_id));
  my $id = $self->param('id');
  if ($id) {
    table('place')->Modify($h,$id);
  } else {
    $h->{user_id}=getUser()->Get('id');
    my $res = table('place')->Create($h);
    $id=$res->{id};
  }

  return "/places/#p$h->{id}";
}



sub ACTION_redir {
  my $self = shift;
  my $l = $self->param('l');
  return "http://zhazhda.ru/unknown_link" unless $l;
  $l="http://$l/" unless $l=~/http/;
  my ($scheme, $host, $path, $query, $frag) = uri_split($l);
  $query="" unless defined $query;
  $path="" unless defined $path;
  my $referer = setting('uri')->{referer} || '';
  $referer=~s/\#.*$//;
  my $db = db();
  $db->Begin();
  $db->Query("lock table click_counter in share mode");
  $path='' if $path eq '/';
  my $res = $db->
    SelectAndFetchOne("click_counter",'*',{host=>$host,path=>$path,query=>$query,
                                           referer=>$referer});

  if ($res) {
    $db->Query("update click_counter set counter = counter + 1, last_time=now() where  host=? and path=? and query=? and referer=?",
               $host,$path,$query,$referer);
  } else {
    $db->Query("insert into click_counter values (?,?,?,?)",
               $host,$path,$query,$referer);
  }
  $db->Commit();
  return $l;
}

sub ACTION_go_journal {
  my $self = shift;
  my $id = $self->param('jid');
  my $j = forum()->LoadJournal($id || 1) || forum()->LoadJournal(1);
  if ($j->{host} eq setting('host')) {
    $self->template('redirect');
    return "/$j->{path}";
  }
  my $ssid = $self->session()->{session};
  return "http://$j->{host}/$j->{path}?ssid=$ssid";
}


sub ACTION_list_journals {
  my $self = shift;
  $self->activeItem('journals');
  $self->template('list_journals');
  return {journals=>forum()->ListJournals()};
}

sub ACTION_users {
  my $self = shift;
  $self->activeItem('users');
  my $list = db()->
    SelectAndFetchAll("select * from fuser where topics>0 and block_type<=1 order by topics desc");
  return {list=>$list};
}

sub ACTION_users_ajax {
  my $self = shift;
  my $nick = $self->param('nick');
  fatal("no nick") unless $nick;
  $nick="$nick%";
  my $list = db()->
    SelectAndFetchAll("select * from fuser where login like '$nick' order by login");
  return {list=>$list};
}


sub ACTION_new_journal {
  my $self = shift;
  #   $self->addNav('journals',
  #                 'newjournal');
  $self->template('newjournal');
  return 1;
}


sub ACTION_gallery {
  my $self = shift;
  my $limit = 40;
  $self->addNav('gallery');
  my $page = $self->param('page');
  my %p = map {$_=>1} $self->param();
  my $all = db()->
    SelectAndFetchOne("select count(*) as all from filesholder_file where type='image' and is_in_gallery");
  my $pages = int($all->{all}/$limit)+ ($all->{all} % $limit ? 1 : 0);
  setContext('all',$all->{all});
  unless (exists $p{page}) {
    $self->template('redirect');
    return "/gallery/?page=last";
  }

  $page=$pages if $page eq 'last';

  my $start = ($page-1)*$limit;
  setContext('pages',$pages);
  setContext('page',$page);

  $start=0 if $start<0;
  $start=$all->{all}-$limit if $start>$all->{all};

  my $list = db()->
    SelectAndFetchAll("select * from filesholder_file where type='image' and is_in_gallery order by id limit $limit offset $start");
  setContext('start',$start);
  setContext('limit',$limit);
  return [reverse @$list];
}

sub ACTION_moderate {
  my $self = shift;
 
#  return undef;
  # TODO Удалять не прошедшие моредацию
  my $limit = 50;
  my $start = $self->param('start')+0;
  my $list = $self->param('list');
  my @l = split(',',$list);
  my $f = forum();
  foreach (@l) {
    my $is_moderated = $self->param("is_moderated_$_") eq 'on' ? 1 : 0;

    my %h;
    if ($is_moderated) {
      $h{is_moderated}=1;
      $h{is_in_gallery}=1
        if $self->param("put_in_gallery_$_") eq 'on';
      table('filesholder_file')->
        Modify(\%h,
               $_);
    } else {
      
      #      $h{is_removed}=1;
    }
    
  }
  my $jid = 1;
  my $where = "not filesholder_file.is_moderated and filesholder_file.type='image' and not filesholder_file.is_in_gallery and filesholder_file.topic_id=topic.id and topic.journal_id=$jid";
  my $all = db()->
    SelectAndFetchOne(qq(select count(*) as all from topic, filesholder_file
                         where $where));
  setContext('all',$all->{all});
  my $list = db()->
    SelectAndFetchAll("select * from topic, filesholder_file where $where order by filesholder_file.id limit $limit offset $start");
  setContext('start',$start);
  setContext('limit',$limit);
  return $list;
}



1;
