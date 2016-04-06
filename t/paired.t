#!perl

use Test::More;
use Test::Mojo;
use experimental 'signatures';
#use warnings FATAL => 'all';

require 'ro';

my $t = Test::Mojo->new;

sub enter {
 $t->websocket_ok('/ready')->send_ok('hello')
   ->message_ok
   ->json_message_like('/welcome' => qr/\d/)
   ->tx
}

my @pair;
push @pair, enter() for 1,2;

# Play once.
$pair[0]->send('rock');
$pair[1]->send('paper');

my @results;
for my $i (0,1) {
  $pair[$i]->on(json => sub($c,$msg) {
      $results[$i] = $msg;
      is $msg->{error}, undef, 'result received'
  });
}

Mojo::IOLoop->timer(0.1 => sub { shift->stop } );
Mojo::IOLoop->start;

is +@results, 2, "got two results";

# Play more times.
for (2,3,4,5) {
  $pair[0]->send('paper');
  $pair[1]->send('scissors');
  @results = ();
  note " ---------------------- game $_ ---------------------------";
  Mojo::IOLoop->timer(0.1 => sub { shift->stop } );
  Mojo::IOLoop->start;
  is_deeply $results[0],
    {
      you      => "lose",
      yours    => "paper",
      opponent => 2,
      theirs   => "scissors",
      game     => $_,
      pair     => 1
    },
    "right results";
  is_deeply $results[1],
    {
      you      => "win",
      yours    => "scissors",
      opponent => 1,
      theirs   => "paper",
      game     => $_,
      pair     => 1
    },
    "right results";
}

done_testing();

