#!/bin/env perl

use strict;
use vars qw($VERSION %IRSSI);

use Irssi;
$VERSION = '1.00';
%IRSSI = (
    authors     => 'citizen42',
    contact     => 'contact@citizen42.fr',
    name        => 'Auto-write',
    description => 'This script kick some ass' .
    license     => 'Beerware',
);


sub fuckyou {
   my($data, $server, $witem, $time, $text) = @_;
   my $string;
   my @strings=('
                        _         FUCK YOU        _','
                       |_|                       |_|','
                       | |         /^^^\         | |','
                      _| |_      (| "o" |)      _| |_','
                    _| | | | _    (_---_)    _ | | | |_','
                   | | | | |\' |    _| |_    | \`| | | | |','
                   |          |   /     \   |          |','
                    \        /  / /(. .)\ \  \        /','
                      \    /  / /  | . |  \ \  \    /','
                        \  \/ /    ||Y||    \ \/  /','
                         \__/      || ||      \__/','
                                   () ()','
                                   || ||','
                                  ooO Ooo        ');
    foreach $string (@strings){
    $server->command("MSG $witem->{name} $string");}
}

sub like {
   my($data, $server, $witem, $time, $text) = @_;
   my $string;
   my @strings=('
       _','
      / )','
    .\' /','
---\'  (____','
       ((__)','
    ._ ((___)','
     -\'((__)','
---.___((_)
');

foreach $string (@strings){
$server->command("MSG $witem->{name} $string");}
}

Irssi::command_bind fuckyou => \&fuckyou;
Irssi::command_bind like => \&like;
