#!perl

use Test::More;
use Test::Mojo;
use experimental 'signatures';

require 'ro';

my $t = Test::Mojo->new;

my @players;
for my $p (0..100) {
  $t->websocket_ok('/ready')
     ->send_ok('hello')
     ->message_ok
     ->message_like(qr/welcome:(.*)/);
  push @players, $t->tx;
}

my $i = 0;
my @played;
for (@players) {
  my $play = [ qw/rock scissors paper/ ]->[++$i % 3];
  push @played, $play;
  $_ = $_->send( $play );
}

my @results;
$i = 0;
for my $p (@players) {
  my $j = $i;
  $p->on(message => sub($c,$msg) { $results[$j] = $msg; });
  ++$i;
}

Mojo::IOLoop->timer(3 => sub { shift->stop } );
Mojo::IOLoop->start;

my $wins   = grep /you: win/,  @results;
my $losses = grep /you: lose/, @results;
my $ties   = grep /tie/,       @results;
is $wins + $losses + $ties, 100, '100 results';
is $wins, $losses, "same number of wins as losses";

done_testing();

