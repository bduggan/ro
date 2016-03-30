#!perl

use Test::More;
use Test::Mojo;
use v5.20;
use experimental 'signatures';

require 'ro';

my $t = Test::Mojo->new;

sub enter {
 $t->websocket_ok('/ready')->send_ok('hello')
   ->message_ok->message_like(qr/welcome: \d/)
   ->tx
}

my @players = map enter(), 1..4;
my @results;
for my $i (0..3) {
  $players[$i]->on(message => sub($c,$msg) { $results[$i] = $msg });
}

Mojo::IOLoop->timer(1 => sub {
   $players[0]->send('rock');
   $players[2]->send('rock');
} );

Mojo::IOLoop->timer(2 => sub {
   $players[1]->send('paper');
   $players[3]->send('paper');
} );

Mojo::IOLoop->timer(4 => sub { shift->stop } );

Mojo::IOLoop->start;

is_deeply \@results, [('tie') x 4], 'four ties';

done_testing();

