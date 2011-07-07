use lib qw(
            /home/danil/projects/dpl/littlesms/
         );


package nz::define;
use dpl::Web::define;
use dpl::System;
use dpl::Context;
use dpl::Db::Database;
use nz::Site;
use nz::Ad;
use nz::Mail;
use nz::User;
use nz::Home;
use nz::Files;
use dpl::Web::Forum::Processor::Login;
use nz::Banner;
use dpl::FilesHolder;
use nz::Journal::Default;
use nz::Journal::Afisha;
use nz::Journal::Foto;
use nz::Journal::Video;
#use nz::Journal::Awards;
#use nz::Journal::Drugoi;

use nz::Object::Journal::Default;
use nz::Object::Journal::Afisha;
use nz::Object::Journal::Foto;
use nz::Object::Journal::Video;

#use nz::Object::Journal::Drugoi;
#use zhazhda::UserHome;


use Config::General;
my %config = Config::General::ParseConfig('/home/danil/projects/nz/utils/convert.conf');

use LittleSMS;
$LittleSMS::DEBUG=1;

new LittleSMS($config{littlesms}->{login}, $config{littlesms}->{key}, , $config{littlesms}->{useSSL});
sms()->setSender('Zhazhda.Ru');
sms()->setBalanceControl( $config{littlesms}->{balance}, $config{littlesms}->{telefon} );


dpl::System::Define('nz','/home/danil/projects/nz/system.xml');

# $ENV{DOCUMENT_ROOT}="/home/danil/projects/nz";
# "$ENV{DOCUMENT_ROOT}/edd5d18abd58ea8ce4272ba67cb2fec7/SAPE.pm" =~
# /^(.+)$/; 

require '/home/danil/projects/nz/edd5d18abd58ea8ce4272ba67cb2fec7/SAPE.pm';

# setting('cities',SuperSelectAndFetchAll('select * from city'));
# setting('categories',SuperSelectAndFetchAll('select * from category
# order by id')); db()->Commit();

# Загружаю в хеш юзверей

$dpl::Db::Database::DS_XML='dev_datasource'
  if `hostname`=~/dapi/;

dpl::Web::Forum::define(dpl::Web::Forum->
                        instance(db=>db(),
                                 files_holder=>dpl::FilesHolder->new('/home/danil/projects/zhazhda/files/')));

1;
