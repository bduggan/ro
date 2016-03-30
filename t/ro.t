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

# player 2
$t->websocket_ok('/ready')
   ->send_ok('hello')
   ->message_ok
   ->message_is('welcome 2');

done_testing();

