#!/usr/bin/env perl

use v5.20;
use experimental 'signatures';
use Mojo::UserAgent;
use Data::Dumper;

my $host = shift || 'rock:8100';
my $url = "ws://$host/ready";
my $ua = Mojo::UserAgent->new;

for my $play (qw/rock scissors/) {

  $ua->websocket($url => sub {
    my ($ua, $tx) = @_;
    if (my $e = $tx->error) {
      print "error: ".Dumper($e);
    }
    say 'WebSocket handshake failed!' and return unless $tx->is_websocket;
    $tx->on(json => sub {
      my ($tx, $hash) = @_;
      say "got " . Dumper($hash);
      #$tx->finish;
    });
    $tx->send('hello');
    $tx->send($play);
  });

}

Mojo::IOLoop->timer(1 => sub { shift->stop });
Mojo::IOLoop->start;

