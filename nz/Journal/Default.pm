package nz::Journal::Default;
use strict;
use Exporter;
use nz::Utils;
# use Date::Parse;
use dpl::Context;
use dpl::System;
# use dpl::Base;
use dpl::Error;
# use dpl::XML;
# use dpl::Log;
use dpl::Db::Database;
use dpl::Db::Filter;
use dpl::Db::Table;
# use URI::Escape;
use el::Web::Form;
use dpl::Web::Forum::Topic;
use dpl::Web::Forum::Journal;

use dpl::Web::Forum::Processor::Base;
use vars qw(@ISA);
@ISA = qw(dpl::Web::Forum::Processor::Base);



sub ACTION_rating {
  my $self = shift;
  my $id = $self->param('id');
  my $r = $self->FileRatingClass();
  return undef
    unless
      $self->CheckReferer('Вы действительно желаете?');

  $r->Rate(getUser()->Get('id'),$id,$self->param('rating'));
  return {item=>$r,
          thanks=>'Спасибо за Ваш голос!'};
}


sub ACTION_video {
  my $self = shift;
  $self->activeItem('video');
  my $j = JournalInstance(1);
#  my $j = $self->journal();
  my @where;
  my @bind;
  #`  push @where,"journal_topic.is_on_main ";
  push @where,"(topic.movies>0 or topic.youtubes>0)";
  return
      {
          topics=>$j->ListTopics({where=>\@where,
                                  bind=>\@bind,
                                  load_video=>1,
                                  limit=>25}),
      };
}

sub ACTION_podcast {
  my $self = shift;
  $self->activeItem('podcast');
  my $j = JournalInstance(1);
#  my $j = $self->journal();
  my @where;
  my @bind;
  #`  push @where,"journal_topic.is_on_main ";
  push @where,"journal_topic.is_on_main and topic.music>0";
  return
      {
          podcasts=>db()->SelectAndFetchAll('select * from fuser where not is_removed and podcast_type>0 order by podcast_name'),
          topics=>$j->ListTopics({where=>\@where,
                                  bind=>\@bind,
                                  load_music=>1}),
      };
}

sub ACTION_podcast_rss {
  my $self = shift;
  return {items=>$self->get_music(50),
          link=>setting('uri')->{home}.'podcast/rss.xml',
          author=>'zhazhda.ru community',
          title=>"Жажда Жизни",
          image=>'http://www.zhazhda.ru/pic/birka.gif',
          description=>'Клубная жизнь в Чебоксарах и за их пределами'};
}


sub template_file {
  my ($self,$file) = @_;
  my %lf = map {$_=>1}
    qw(edit_event.html edit_file.html edit_gallery.html edit_topic.html
       new_event.html edit_vote.html new_vote.html new_gallery.html new_topic.html
       podcast.html
       show_draft_topic.html show_file.html show_topic.html
      );
  return $self->SUPER::template_file() unless $file;
  my $path = $self->{journal}->{templ_path};
  $path='default/' if $path ne 'default/' && $lf{$file};
  return $self->{template_file} = "journal/$path$file";
}


# sub template_file {
#   my ($self,$file) = @_;
#   return $self->SUPER::template_file() unless $file;
#   my $t = $self->{journal}->{templ_path} || 'default';
#   return $self->{template_file} = "journal/$t/$file";
# }

sub LoadTopic {
  my ($self,$id)=@_;
  $self->LoadTopicAndInitJournal($id) || return undef;
  return undef
    if $self->{topic}->{is_removed} && !$self->user()->HasAccess('admin');

  my $t = context('title');
  setContext('title',$t ? "$t / $self->{topic}->{subject}" : $self->{topic}->{subject});
  setContext('next_topic',$self->user()->GetNextFreshTopic($id))
    if context('next_topic') && context('next_topic')->{id}==$id;
  return $self->{topic};
}

sub ACTION_mark_as_read {
  my $self = shift;
  # FIX!
#   my $issue = $self->param('issue');
#   $issue = table('journal_issue')->Load($issue) || fatal("No such issue $issue");
#   my $j = $self->LoadAndInitJournal($issue->{journal_id}) ||
#     fatal("No such journal '$issue->{journal_id}'");
#   $self->{journal_instance}->MarkAsReadIssue($issue->{id},$self->param('topics'));
#  my $r =  setting('uri')->{referer};
  #return "http://$j->{host}/$j->{path}" unless $r;
  $self->template('global_redirect');
#  return $r;
}


sub lookup {
  my ($self,$query) = @_;
  #  my %actions = $self->_actions();
  return 1 unless $self->{page}->{action} eq 'show_topic';
  if ($query=~/^(\d+).html$/) {
    $self->{page}->{action}='show_topic';
    my $topic = $self->LoadTopic($1);
    return $topic if $topic;
  }
  $self->{page}->{action}='notfound';
  return 1;
}

sub ACTION_archive {
  my $self = shift;
  $self->addNav('archive');
  $self->LoadGallery();
  my $j = $self->LoadAndInitJournal($self->param('jid') || 1) ||
    fatal("no such journal");
#  $self->LoadIssues();
  return ;
}

sub ACTION_edit_journal {
  my $self = shift;
    return undef
    unless
      $self->CheckReferer('Вы действительно желаете?');

  $self->addNav('edit_journal');
  my $id = $self->param('jid');
  my $j = JournalInstance($id) || fatal("No such journal");
  my $p = $self->CheckParams(qw(name));
  return $self->ACTION_edit_journal_form()
    unless $p;
  my $pp = $self->GetParams(qw(description access_topic_status access_journal access_topic access_comment comment_list_mode min_raters topic_list_mode top_days_to_list days_to_list respect_links));
  $pp->{access_topic_status}=$pp->{access_topic_status} eq 'on' ? 1 : 0;
  my $res = $j->Edit({%$p,%$pp});
  return "/edit_journal_form?jid=$id";

}

sub ACTION_members {
  my $self = shift;
#  $self->addNav('journal_members');
  my $j = JournalInstance($self->param('jid'));
  my $journal = $j->Get();
  setContext('journal',$journal);
  return {members=>$j->MembersList()};
}

sub ACTION_add_member {
  my $self = shift;
    return undef
    unless
      $self->CheckReferer('Вы действительно желаете?');

  my $jid = $self->param('jid');
  my $j = JournalInstance($jid);
  $j->AddMember($self->param('talker'));
  return "/members?jid=$jid";
}

sub ACTION_del_member {
  
  my $self = shift;
    return undef
    unless
      $self->CheckReferer('Вы действительно желаете?');

  my $jid = $self->param('jid');
  my $j = JournalInstance($jid);
  $j->DeleteMember($self->param('user_id'));
  return "/members?jid=$jid";
}



sub ACTION_edit_journal_form {
  my $self = shift;
    return undef
    unless
      $self->CheckReferer('Вы действительно желаете?');

  $self->addNav('edit_journal');
  #   setContext('access_list',[
  #                             #{id=>"111",name=>'Закрытый',desc=>'Просматривать и вести его могут только избранные.'},
  #                             {id=>"211",name=>'Ограниченный',desc=>'Просматривать могут все, но вести и комментировать только избранные.'},
  #                             {id=>"212",name=>'Ограниченный с комментированием',desc=>'Просматривать и комментировать могут все, но вести только избранные.'},
  #                             {id=>"222",name=>'Общедоступный',desc=>'Просматривать, вести и комментировать могут все.'}]);
  setContext('access_list_journal',[{id=>"1",name=>'Избранные'},
				    {id=>"2",name=>'Все реалы'},
				    {id=>"3",name=>'Все зарегистрированные'},
				    {id=>"4",name=>'Даже анонимы'}]);
  setContext('access_list_topic',[{id=>"0",name=>'Только хозяин журнала'},
				  {id=>"1",name=>'Избранные'},
				  {id=>"2",name=>'Все реалы'},
				  {id=>"3",name=>'Все зарегистрированные'},
				  {id=>"4",name=>'Даже анонимы'}]);
  setContext('access_list_comment',[{id=>"0",name=>'Никто'},
                            {id=>"1",name=>'Избранные'},
                            {id=>"2",name=>'Все реалы'},
				    {id=>"3",name=>'Все зарегистрированные'},
				    {id=>"4",name=>'Даже анонимы'}]);
  setContext('comment_list_modes',
             [{id=>1,name=>'Деревом'},
              {id=>2,name=>'Списком'}]);
  
  #   setContext('issue_types',
  #              [{id=>0,name=>'Выпуски не используются'},
  #               {id=>1,name=>'Раз в неделю'},
  #               {id=>2,name=>'Раз в месяц'}]);

  setContext('topic_list_modes',
             [{id=>0,name=>'По-дням'},
              {id=>1,name=>'По-порядку'}]);
  my $j = JournalInstance($self->param('jid'));
  my $journal = $j->Get();
#  $journal->{access}=$j->Get('access_journal').$j->Get('access_topic').$j->Get('access_comment');
  return setContext('fields',$journal);
}

sub journal { $_[0]->{journal_instance} }

sub ACTION_load_file {
  
  my $self = shift;
    return undef
    unless
      $self->CheckReferer('Вы действительно желаете?');

  my $topic = $self->LoadTopicAndInitJournal($self->param('tid')) || return undef;
#  my $journal = forum()->LoadJournal($topic->{journal_id});
  my %o;
  $o{put_logo}=$self->param('put_logo');
  $o{rotate}=$self->param('rotate');
  if ($o{put_logo}) {
    #    $o{logo_basic} = GD::Image->new('/home/danil/projects/nz/pic/za2_80x34.gif') ||
    $o{logo_basic} = GD::Image->new('/home/danil/projects/nz/pic/logo80x30.gif') ||
      fatal("Error open file: logo1");
    $o{logo_gallery} = GD::Image->new('/home/danil/projects/nz/pic/logo50x19.gif') ||
      fatal("Error open file: logo2");
  }

  my $res = $self->{topic_instance}->
    LoadFile($self->param('file'),
             $self->param('title'),
             \%o);
  #  return "/edit_topic?id=$self->{topic}->{id}#file";
  return "/topics/$topic->{id}.html?file=1#file";
}

sub ACTION_add_comment {
  my $self = shift;
    return undef
    unless
      $self->CheckReferer('Вы действительно желаете?');

  my $p = $self->GetParams(qw(parent_id text file_id));
  $p->{parent_id}=undef unless $p->{parent_id};
  #$self->journal()->
  my $topic = $self->LoadTopicAndInitJournal($self->param('tid')) || return undef;
  $self->template('redirect');
  if ($self->param('gallery')) {
     my $res = $self->{topic_instance}->PostComment($p)
  	if $p->{text};
     return  "/topics/$topic->{id}.html?gallery=1#m$res->{id}";
  } else {
	  return "/topics/$topic->{id}.html#m$p->{parent_id}"
    unless $p->{text};
  my $res = $self->{topic_instance}->PostComment($p);
  return $p->{file_id} ?
    "/holder/$p->{file_id}.html#m$res->{id}" :
    "/topics/$topic->{id}.html#m$res->{id}";
  }
}



sub ACTION_do_vote {
  my $self = shift;
    return undef
    unless
      $self->CheckReferer('Вы действительно желаете?');

  my $p = $self->GetParams(qw(tid id));
  my $topic = $self->LoadTopicAndInitJournal($self->param('tid')) || return undef;
  if ($self->user()->IsLoaded() && $self->user()->Get('mobile_checked')) {
    my $res = $self->{topic_instance}->DoVote($p->{id});
  }
  $self->template('redirect');
  return "/topics/$topic->{id}.html";
}



sub new_topic_form {
  my $self = shift;
  $self->activeItem('new_topic');
  $self->template('new_topic');
  
  if ($self->param('topic_type') eq 'event') {
    $self->template_file('new_event.html');
    
  } elsif ($self->param('topic_type') eq 'gallery') {
    $self->template_file('new_gallery.html');
		
  } elsif ($self->param('topic_type') eq 'vote') {
    $self->template_file('new_vote.html');
    
  } else {
    $self->template_file('new_topic.html');
  }

  setEventDates();
  setEventTimes();
  setPlaces();

  setEvents();
  
  return 1;
}

sub setEvents {
  my $res = db()->SelectAndFetchAll("select * from topic where not is_removed and topic_type='event' and event_date<=date(now()) and event_date>=date( now() - interval '10 days') order by event_date desc");
  foreach (@$res) {
    my $date = dpl::Web::Forum::Processor::Base::filter_date_afisha($_->{event_date});
    my $e = $_->{event_place};
    $e=substr($e,0,20).'..' if length($e)>25;
    my $d = "$date, $e";
    my $s = dpl::Web::Forum::Processor::Base::filter_escape_subject_short($_->{subject},120-length($d));
    $_->{name}="$d - $s";
  }
  setContext('events',$res);
}


sub ACTION_new_topic {
  my $self = shift;
#   my $form = NewForm('edit',
#                      $self->GetParams(qw(topic_type
#                                          subject text)));
#  setContext('form',$form);
  return $self->new_topic_form();
}


sub ACTION_post_topic {
  my $self = shift;
  return undef
    unless
      $self->CheckReferer('Вы действительно желаете?');

  my $form = NewForm('edit',
                     $self->GetParams(qw(topic_type comment_list_mode upload_access
                                         event_id
                                         draft_category_id
                                         event_place event_date event_time place_id
                                         place_category_id
                                         subject text)));
	my $type = $self->param('topic_type');
	
	my $votes=$self->ValidateVotes($form);
  $self->ValidateTopic($type,$form);
  #die join(',',%{$form->{fields}});
  setContext('form',$form);
  return $self->new_topic_form()
    if $form->Errors();
  my $res;
  $res = SaveDraftTopic($form->Fields(),$votes);
  TopicInstance($res->{id})->
    PublishTopic()
      if $self->param('publish');
  return "/topics/$res->{id}.html?done=1";
}

sub ValidateTopic {
  my ($self,$type,$form) = @_;
  if ($type eq 'event') {
    $form->Validate('notempty',
                    qw(subject text event_date event_time place_category_id));
    if ($form->Field('place_id') eq 'no') {
      $form->AddError('place_id','notempty');
    } elsif (!$form->Field('place_id') && !$form->Field('event_place')) {
      $form->AddError('place_id','notempty');
      $form->AddError('event_place','notempty');
    }
    if ($form->Field('place_category_id') eq 'no') {
      $form->AddError('place_category_id','notempty');
    }
  } elsif ($type eq 'gallery') {
    $form->Validate('notempty',
                    qw(subject text));

    if ($form->Field('event_id') eq 'no') {
      $form->AddError('event_id','notempty');
    } elsif (!$form->Field('event_id')) {
      if ($form->Field('place_id') eq 'no') {
        $form->AddError('place_id','notempty');
      } elsif (!$form->Field('place_id') && !$form->Field('event_place')) {
        $form->AddError('place_id','notempty');
        $form->AddError('event_place','notempty');
      }
      if ($form->Field('place_category_id') eq 'no') {
        $form->AddError('place_category_id','notempty');
      }
    }
  } else {
    $form->Validate('notempty',
                    qw(subject text));
  }
}


sub ValidateVotes {
	my ($self,$form) = @_;
	my @votes;
	if ($self->param('topic_type') eq 'vote') {

		foreach (0..$dpl::Web::Forum::Topic::VOTES_COUNT) {
			my $v = $self->param("vote$_");
			$v=~s/^\s+//g;
			$v=~s/\s+$//g;
			$v='' unless $v;
			push @votes, $v;
	#		$form->{fields}->{"vote$_"}=$v;
		}
	}
	setContext('votes',\@votes);
	
	return \@votes;
}


sub CreateSplashCookie {
  my ($self,$name,$value) = @_;
  my $domain = setting('uri')->{current}->hostname();
  my $path = setting('uri')->{home};
  $path=~s/http:\/\/$domain//;
  return new CGI::Cookie(-name=>$name,
                         -value=>$value,
                         -expires => '+120d',
                        );
}

sub CheckSplash {
  my $self = shift;
  return 0 unless context('banners')->{splash};
  my $name = 'zhazhda_splash2';
  my $s = $self->cookies()->{$name};
  my $today = filter('date')->ToSQL(today());
  if (!$s || $s->value() ne $today) {
    $self->addCookie($self->CreateSplashCookie($name,$today));
    $self->template('splash');
    return 1;
  }
  return 0;
}

sub setAfisha {
  my %afisha;
  my $categories = join(' or ',map {"place_category_id=$_"} qw(2 3 4 1 7));

  $afisha{today}=db()->
    SelectAndFetchAll(qq(select topic.*, to_char(topic.event_time,
'H24:MI') as event_time from topic
where journal_id=2 and topic_type='event' and event_date=date(now()) and
not is_removed and ($categories) order by topic.event_time
));
  
  $afisha{tomorrow}=db()->
    SelectAndFetchAll(qq(select topic.*,
to_char(topic.event_time,'H24:MI') as event_time from topic
where journal_id=2 and topic_type='event'  and event_date=date(now() +
'1 day') and not is_removed and ($categories)  order by topic.event_time
));
  
  $afisha{soon}=db()->
    SelectAndFetchAll(qq(select topic.*,
to_char(topic.event_time,'H24:MI') as event_time from topic
where journal_id=2 and topic_type='event'  and event_date>date(now() +
'1 day') and not is_removed and ($categories)  order by
topic.event_date, topic.event_time limit 7
));
}

sub ACTION_show_journal {
  my $self = shift;
  
  return 1 if $self->CheckSplash();
  
  $self->addNav('journal');
  $self->template_file('show_journal.html');
  $self->LoadGallery();
  my $j = $self->journal();
  $j->UpdateLastViewInfo();

  my $days = $j->Get('days_to_list');
  my $date_from = filter('date')->ToSQL(today()-60*60*24*$days);
  my $tdays = $j->Get('top_days_to_list');

  my @where;
  my @bind;

  my $videos = db()->SelectAndFetchAll('select * from videos order by timestamp desc limit 5');
	
	setContext('videos',$videos);
	
  my $afisha = JournalInstance(2);

#     my $hot_date_from = filter('date')->ToSQL(today()-2*60*60*24);
  #     my $top_date_from = filter('date')->ToSQL(today()-$tdays*60*60*24);
  #     push @w_hot,"is_hot and not is_on_top and topic.rating>=4.0 and (journal_topic.issue_id=? or (journal_topic.issue_id=? and topic.update_time>=? and topic.create_time>=?))";
  
  push @where,"journal_topic.is_on_main";

  my $s = $self->session();
 
  return  {journal=>$j->Get(),
           afisha=>$afisha->ListTopics({where=>["not event_past","topic_type='event'"
                                                #,"topic.is_moderated"
                                                # клубы и концерты
                                                #                                             "place_id=?"
                                               ],
                                        # or ((event_date=date(now() + '1 day') or event_date=date(now())) and (place_category_id=1 or place_category_id=4))"],
                                        order=>'event_date, event_time',
                                        #                                 bind=>[5],
                                        #                                   get_fotos=>0,
                                        #                                   sort_result=>0
                                       }),
           topics=>$j->ListTopics({where=>\@where,
                                   bind=>\@bind,
                                   get_fotos=>1,
                                   sort_result=>1}),
           #           hot=>$j->ListTopics({where=>\@w_hot,
           #                                order=>'timestamp desc',
           #                                bind=>\@b_hot,
           #                                sort_result=>1
           #                               })
          };
}


sub ACTION_show_topic {
  my $self = shift;
#  $self->SetBackurl(context('journal')->{path});
#  $self->LoadGallery(10);
  setContext('topic',$self->{topic});
  # номер комментария для редактирования
  setContext('edit_comment',$self->param('edit'));
  setContext('load_file',$self->param('file'));
  if ($self->{topic}->{topic_type} eq 'vote') {
    $self->template_file('show_vote.html');
	} elsif ($self->param('gallery')) {
		$self->template_file('show_topic_gallery.html');
  } else {
    $self->template_file('show_topic.html');
  }
	$self->template_file('show_draft_topic.html')
		unless $self->{topic}->{journal_id};
  #  die $self->{topic_instance};
  return $self->{topic_instance}->ShowTopic($self->{journal_instance},$self->param('page'));
}

sub ACTION_delete_comment {
  my $self = shift;
    return undef
    unless
      $self->CheckReferer('Вы действительно желаете?');

  my $id = $self->param('id');
  my $tid = $self->param('tid');
  my $topic = $self->LoadTopicAndInitJournal($tid) || return undef;
  my $last_id = $self->{topic_instance}->DeleteComment($id,$self->param('deep'));
  return "/topics/$tid.html#m$last_id";
}

sub ACTION_edit_comment {
  my $self = shift;
    return undef
    unless
      $self->CheckReferer('Вы действительно желаете?');

  my $id = $self->param('id');
  my $tid = $self->param('tid');
  my $topic = $self->LoadTopicAndInitJournal($tid) || fatal("no such topic");
  my $text = $self->param('text');
  my $last_id = $self->{topic_instance}->
  EditComment({text=>$text},$id);
  return "/topics/$tid.html#m$id";
}


sub ACTION_topic_to_draft {
  my $self = shift;
    return undef
    unless
      $self->CheckReferer('Вы действительно желаете?');

  my $id = $self->param('id');
  TopicInstance($id)->MoveTopicToDraft();
  return "/topics/$id.html";
}


sub ACTION_edit_topic_form {
  my $self = shift;
    return undef
    unless
      $self->CheckReferer('Вы действительно желаете?');

  $self->template('edit_topic');
  my $topic_id = $self->param('id');
  my $topic = $self->
    LoadTopicAndInitJournal($topic_id) ||
        fatal("no such topic");
  my $t = $self->param('topic_type') || $self->{topic}->{topic_type};
#  $t='' if $t eq 'basic';
  #  $self->{topic}->{topic_type}=$t;
  if ($t eq 'gallery') {
    $self->template_file('edit_gallery.html');
  } elsif ($t eq 'event') {
    $self->template_file('edit_event.html');
  } elsif ($t eq 'vote') {
    $self->template_file('edit_vote.html');
  } else {
    $self->template_file('edit_topic.html');
  }
  # $self->SetBackurl(context('journal')->{path});
  setContext('form',{name=>'edit',
                     fields=>$self->{topic}})
    unless context('form');
  setEventDates();
  setEventTimes();
  setEvents();
  setPlaces();
#   setContext('categories',$self->{journal_instance}->GetCategories())
#     if $self->{journal_instance};
  my $res=$self->{topic_instance}->ShowTopic($self->{journal_instance});
	
	my @votes;

	if ($res->{topic}->{topic_type} eq 'vote') {
		foreach my $v (@{$res->{votes}}) {
			push @votes,$v->{name};
		}
		setContext('votes',\@votes);
		
	}
	
	return $res;
	
}

sub setPlaces {
  my $places = db()->SelectAndFetchAll('select * from place where is_moderated order by name');
  my $category = db()->SelectAndFetchAll('select * from place_category order by name');
  setContext('places',$places);
  setContext('place_categories',$category);
}

sub setEventTimes {
  my @times;
  my $time;
  foreach my $t (0..23) {
    foreach my $s (0..11) {
      my $tt= $t < 10 ? "0$t": $t;
      $s=$s*5;
      my $ss= $s < 10 ? "0$s": $s;
      push @times,{id=>"$tt:$ss",
                   name=>"$tt:$ss"};
    }
  }
  setContext('times',\@times);
}

sub setEventDates {
  my @dates;
  my @past;
  my $date=today();
  my $past=today();
  
  foreach (1..33) {
    push @dates,{id=>$date,
                 name=>dpl::Web::Forum::Processor::Base::filter_date_afisha($date)};
    push @past,{id=>$past,
                name=>dpl::Web::Forum::Processor::Base::filter_date_afisha($past)};
    $date=$date->NextDay();
    $past=$past->PrevDay();
  }

  setContext('dates',\@dates);
  setContext('past_dates',\@past);
}

sub ACTION_publish_topic {
  my $self = shift;
  return undef
    unless
      $self->CheckReferer('Вы действительно желаете?');

  my $id = $self->param('id');
  # TODO access!
  #my $jid = $self->param('jid');
  #  my $topic = $self->LoadTopicAndInitJournal($id) || fatal("no such topic");
  TopicInstance($id)->PublishTopic($self->param('jid'));
  return "/topics/$id.html";
}

sub ValiateTopic {
  my ($self,$type,$form) = @_;
  if ($type eq 'event') {
    $form->Validate('notempty',
                    qw(subject text event_date event_time place_category_id));
    if ($form->Field('place_id') eq 'no') {
      $form->AddError('place_id','notempty');
    } elsif (!$form->Field('place_id') && !$form->Field('event_place')) {
      $form->AddError('place_id','notempty');
      $form->AddError('event_place','notempty');
    }
    if ($form->Field('place_category_id') eq 'no') {
      $form->AddError('place_category_id','notempty');
    }
  } elsif ($type eq 'gallery') {
    $form->Validate('notempty',
                    qw(subject text));

    if ($form->Field('event_id') eq 'no') {
      $form->AddError('event_id','notempty');
    } elsif (!$form->Field('event_id')) {
      if ($form->Field('place_id') eq 'no') {
        $form->AddError('place_id','notempty');
      } elsif (!$form->Field('place_id') && !$form->Field('event_place')) {
        $form->AddError('place_id','notempty');
        $form->AddError('event_place','notempty');
      }
      if ($form->Field('place_category_id') eq 'no') {
        $form->AddError('place_category_id','notempty');
      }
    }
  } else {
    $form->Validate('notempty',
                    qw(subject text));
  }
	my $subject = $form->Field('subject');
	my $ucs=$subject;
	my $tcs=$subject;
	#QWERTYUIOPASDFGHJKLZXCVBNM
	$ucs=~s/[^ЁЙЦУКЕНГШЩЗХЪЭЖДЛОРПАВЫФЯЧСМИТЬБЮ]//g;
	$tcs=~s/[^."']//g;
	my $l = length($ucs)-length($tcs);
	if ($l>5) {
		$form->AddError('subject','toomanyuppercase');
	}
}

sub ACTION_edit_topic {
  my $self = shift;
  return undef
    unless
      $self->CheckReferer('Вы действительно желаете?');


  my $form = NewForm('edit',
                     $self->GetParams(qw(topic_type comment_list_mode upload_access
                                         draft_category_id
                                         event_id
                                         event_place event_date event_time place_id
                                         place_category_id
                                         subject text)));
  
  my $type = $self->param('topic_type');
  $self->ValidateTopic($type,$form);

	
	my $votes=$self->ValidateVotes($form);
#	die $votes->[0];
	
  setContext('form',$form);
  return $self->ACTION_edit_topic_form()
    if $form->Errors();
  
  my $id = $self->param('id');
  my $topic = $self->LoadTopicAndInitJournal($id) || fatal("no such topic");
  my $res = $self->{topic_instance}->Edit($form->Fields(),$votes);
  $self->{topic_instance}->PublishTopic()
    if $self->param('publish');
  return "/topics/$id.html";
}

sub ACTION_rate_topic {
  my $self = shift;
    return undef
    unless
      $self->CheckReferer('Вы действительно желаете?');

  my $p = $self->GetParams(qw(topic_id rate));
  my $topic = $self->LoadTopicAndInitJournal($p->{topic_id}) || fatal("no such topic $p->{topic_id}");
  my $res = $self->{topic_instance}->Rate($p->{rate});
  return "/topics/$p->{topic_id}.html#rating";
}

sub ACTION_igo_topic {
    my $self = shift;
    my $p = $self->GetParams(qw(topic_id));
    if ($self->user()->IsLoaded()) {
        return undef
            unless
                $self->CheckReferer('Вы действительно желаете?');
        my $topic = $self->LoadTopicAndInitJournal($p->{topic_id}) || fatal("no such topic $p->{topic_id}");
        my $res = $self->{topic_instance}->SetIgo();
    }
  return $self->param('gallery') ? "/topics/$p->{topic_id}.html?gallery=1" : "/topics/$p->{topic_id}.html#igos";
}

sub ACTION_igo_topic_no {
  my $self = shift;
  return undef
    unless
      $self->CheckReferer('Вы действительно желаете?');

  my $p = $self->GetParams(qw(topic_id));
  my $topic = $self->LoadTopicAndInitJournal($p->{topic_id}) || fatal("no such topic $p->{topic_id}");
  my $res = $self->{topic_instance}->UnsetIgo();
  return "/topics/$p->{topic_id}.html#igos";
}





sub ACTION_change_charset {
  my $self = shift;
  my $topic = $self->LoadTopicAndInitJournal($self->param('id')) || fatal("no such topic");
  my $res = $self->{topic_instance}->ChangeCharset();
  return "/topics/$self->{topic}->{id}.html";
}


sub ACTION_subscribe {
  my $self = shift;
    return undef
    unless
      $self->CheckReferer('Вы действительно желаете?');

  my $topic = $self->LoadTopicAndInitJournal($self->param('id')) || fatal("no such topic");
  my $res = $self->{topic_instance}->Subscribe();

  my $r =  setting('uri')->{referer};
  return "/topics/$self->{topic}->{id}.html" unless $r;

  $self->template('global_redirect');
  return $r;
}

sub ACTION_unsubscribe {
  my $self = shift;
    return undef
    unless
      $self->CheckReferer('Вы действительно желаете?');

  my $topic = $self->LoadTopicAndInitJournal($self->param('id')) || fatal("no such topic");
  my $res = $self->{topic_instance}->Unsubscribe();

  my $r =  setting('uri')->{referer};
  return "/answers/" unless $r;
  $self->template('global_redirect');
  return $r;
}



sub ACTION_delete_topic {
  my $self = shift;
    return undef
    unless
      $self->CheckReferer('Вы действительно желаете?');

  my $topic = $self->LoadTopicAndInitJournal($self->param('id')) || return undef;
  $self->{topic_instance}->Delete();
  return $topic->{journal_id} ? "/$self->{journal}->{path}" : '/draft/';
}


# Меняет статус топика
sub ACTION_change_topic_status {
  my $self = shift;
    return undef
    unless
      $self->CheckReferer('Вы действительно желаете?');
 
  my $tid = $self->param('id');
  my $jid = $self->param('jid');
  if ($jid) {
  $self->LoadAndInitJournal($jid);
  my %statuses = (is_red=>1,is_bold=>1,is_cold=>1,is_on_top=>1,
                  is_on_main=>1,image_mode=>1,is_sticky=>1,is_hot=>1);
  my @p = $self->param();
  my %h;
  foreach (@p) {
    $h{$_}=$self->param($_) if exists $statuses{$_};
  }
  $self->{journal_instance}->ChangeTopicStatus($tid,\%h) if %h;
  } else {
  my $topic = $self->LoadTopic($tid);	  	
  my %statuses = (has_igo=>1,is_moderated=>1,);
  my @p = $self->param();
  my %h;
  foreach (@p) {
    $h{$_}=$self->param($_) if exists $statuses{$_};
  }
  $self->{topic_instance}->Edit(\%h) if %h;
  }
  return "/topics/$tid.html";
}

sub ACTION_topic_image {
  my $self = shift;
    return undef
    unless
      $self->CheckReferer('Вы действительно желаете?');

  my $tid = $self->param('topic_id');
  my $id = $self->param('id');
  my $topic = $self->LoadTopicAndInitJournal($tid) || fatal("no such topic $tid");
  my $res = $self->{topic_instance}->
    SetImage($id);
  my $r =  setting('uri')->{referer};
  $self->template('global_redirect');
  return $r;
}



1;

