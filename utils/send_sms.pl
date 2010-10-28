#!/usr/bin/perl
use strict;
use Text::Iconv;
use URI::Escape;
use HTTP::Lite;

my $converter = Text::Iconv->new("koi8-r", "cp1251");

my $message='test';

my $phone='79023270019';

$message=uri_escape($converter->convert($message));
my $url = "http://www.shgsm.ru/esme/transmitter.php?id=DC16-847R&daddr=$phone&msg=$message";
my $http = new HTTP::Lite;
my $req = $http->request($url) or return undef;
my $res = $http->body();
print STDERR "send SMS $message to $phone: $res\n";
print $res =~ /OK/;
