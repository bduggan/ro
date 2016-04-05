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

Mojo::IOLoop->timer(1 => sub { shift->stop } );
Mojo::IOLoop->start;

is +@results, 2, "got two results";

# Play more times.
for (1) {
  $pair[0]->send('paper');
  $pair[1]->send('scissors');
  @results = ();
  diag " ---------------------- next game ---------------------------";
  Mojo::IOLoop->timer(5 => sub { shift->stop } );
  Mojo::IOLoop->start;
  is_deeply $results[0], { you=> "lose", opponent=> 2, yours=> "paper", theirs=> "scissors", game => 1 + $_}, "right results";
  is_deeply $results[1], { you=> "win",  opponent=> 1, yours=> "scissors", theirs=> "paper", game => 1 + $_}, "right results";
}

done_testing();

