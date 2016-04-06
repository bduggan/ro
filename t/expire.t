#!perl

use Test::More;
use Test::Mojo;
use v5.20;
use experimental 'signatures';

require 'ro';

my $t = Test::Mojo->new;

sub enter {
 $t->websocket_ok('/ready')->send_ok('hello')
   ->message_ok
   ->json_message_like('/welcome' => qr/\d/)
   ->tx
}

sub go {
    my $s = shift || 0.1;
    Mojo::IOLoop->timer($s => sub { shift->stop } );
    Mojo::IOLoop->start;
}

$t->get_ok('/games')
  ->status_is(200)
  ->json_is('/available' => 0);

my $p1 = enter();
my $r1; # result 1
$p1->on(json => sub($c,$msg) { $r1 = $msg; });

$p1->send('rock');
go(0.2);
$t->get_ok('/games')->status_is(200)->json_is('/available' => 1);
go(3);

$p1->send('paper');
my $res = go(0.1);
is $r1->{error}, undef, "Played again";
my $p2 = enter();
my $r2;
$p1->on(json => sub($c,$msg) { $r2 = $msg; });
$p2->send('rock');
go(0.1);
is $r2->{you}, 'win', 'rock wins';

done_testing();
