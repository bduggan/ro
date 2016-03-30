#!perl

use Test::More;
use Test::Mojo;
use experimental 'signatures';

require 'ro';

my $t = Test::Mojo->new;

# player 1
$t->websocket_ok('/ready')
   ->send_ok('hello')
   ->message_ok
   ->message_is('welcome: 1');
my $p1 = $t->tx;

# player 2
$t->websocket_ok('/ready')
   ->send_ok('hello')
   ->message_ok
   ->message_is('welcome: 2');
my $p2 = $t->tx;

$p1 = $p1->send('rock');
$p2 = $p2->send('scissors');

diag 'playing';
my $p1_result;
my $p2_result;
$p1->on(message => sub($c,$msg) { $p1_result = $msg; });
$p2->on(message => sub($c,$msg) { $p2_result = $msg; });
diag 'waiting';
Mojo::IOLoop->timer(2 => sub { shift->stop } );
Mojo::IOLoop->start;
is $p1_result, "winner: rock";
is $p2_result, "winner: rock";

done_testing();

