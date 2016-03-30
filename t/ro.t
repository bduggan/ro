#!perl

use Test::More;
use Test::Mojo;

require 'ro';

my $t = Test::Mojo->new;

# player 1
$t->websocket_ok('/ready')
   ->send_ok('hello')
   ->message_ok
   ->message_is('welcome 1');
my $p1 = $t->tx;

# player 2
$t->websocket_ok('/ready')
   ->send_ok('hello')
   ->message_ok
   ->message_is('welcome 2');
my $p2 = $t->tx;

$p1 = $p1->send('rock');
$p2 = $p2->send('scissors');

$p1->on(message => sub { print "@_\n" });
$p2->on(message => sub { print "@_\n" });

Mojo::IOLoop->timer(12 => sub { shift->stop } );
Mojo::IOLoop->start;

done_testing();

