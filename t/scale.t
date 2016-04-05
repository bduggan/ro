#!perl

use Test::More;
use Test::Mojo;
use experimental 'signatures';

require 'ro';

my $t = Test::Mojo->new;
$t->ua->inactivity_timeout(120);

my $count = 4;

my @players;
for my $p (1..$count) {
  $t->websocket_ok('/ready')
     ->send_ok('hello')
     ->message_ok
     ->json_message_like('/welcome' => qr/\d/);
  push @players, $t->tx;
}

my $i = 0;
for (@players) {
  $_->send( [ qw/rock paper scissors/ ]->[++$i % 3] );
}

my @results;
$i = 0;
for my $p (@players) {
  my $j = $i;
  $p->on(json => sub($c,$msg) { $results[$j] = $msg; });
  ++$i;
}

Mojo::IOLoop->timer(3 => sub { shift->stop } );
Mojo::IOLoop->start;

my $wins   = grep {$_->{you} eq 'win'}  @results;
my $losses = grep {$_->{you} eq 'lose'} @results;
my $ties   = grep {$_->{you} eq 'tie'}  @results;
is $wins + $losses + $ties, $count, "$count results";
is $wins, $losses, "same number of wins as losses";

done_testing();

