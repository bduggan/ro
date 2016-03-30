#!perl

use Test::More;
use Test::Mojo;
use experimental 'signatures';

require 'ro';

my $t = Test::Mojo->new;

sub enter {
 $t->websocket_ok('/ready')->send_ok('hello')
   ->message_ok->message_like(qr/welcome: \d/)
   ->tx
}

my @pair;
push @pair, enter() for 1,2;

# Play once.
$pair[0]->send('rock');
$pair[1]->send('paper');

my @results;
for my $i (0,1) {
  $pair[$i]->on(message => sub($c,$msg) { $results[$i] = $msg });
}

Mojo::IOLoop->timer(1 => sub { shift->stop } );
Mojo::IOLoop->start;

is +@results, 2, "got two results";

# Play again.
$pair[0]->send('paper');
$pair[1]->send('scissors');

@results = ();

Mojo::IOLoop->timer(1 => sub { shift->stop } );
Mojo::IOLoop->start;

is $results[0], 'winner: scissors, you: lose';
is $results[1], 'winner: scissors, you: win';

done_testing();

