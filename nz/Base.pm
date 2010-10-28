package nz::Base;
use strict;
use dpl::Web::Processor::Access;
use dpl::Context;
use dpl::System;
use dpl::Error;
use dpl::DataType::DateTime;
use dpl::Db::Table;
use dpl::Db::Database;
use dpl::Db::Filter;
use dpl::Web::Banner;
use Exporter;
use nz::Utils;
#use Template::Plugin;
use nz::Object::User;
use URI::Escape;
use URI::Split  qw(uri_split uri_join);
use Number::Format qw(:subs);

#use Class::Loader;
use Class::Rebless;
use vars qw(@ISA
            @EXPORT
            @banners_positions);

@banners_positions = qw(top splash bottom middle left01 left02 left03 left04 left05 left06 left07 left08 left09 left10 left11 left12);

@ISA = qw(Exporter
          dpl::Web::Processor::Access
         );

@EXPORT = qw(web_error);


die 'no nz::base';
1;
