#!/usr/bin/env perl

use v5.20;
use experimental 'signatures';
use Mojo::UserAgent;
use Data::Dumper;
use Benchmark::Timer;

my $host = shift || 'rock:8100';
$host =~ s[http://][];
my $url = "ws://$host/ready";
my $ua = Mojo::UserAgent->new;

my %results;

for my $i (1..1000) {
  for my $play (qw/rock scissors/) {

    $ua->websocket($url => sub {
      my ($ua, $tx) = @_;
      if (my $e = $tx->error) {
        print "error: ".Dumper($e);
      }
      say 'WebSocket handshake failed!' and return unless $tx->is_websocket;
      $tx->on(json => sub {
        my ($tx, $hash) = @_;
        #say $hash->{welcome} // $hash->{you} // 'no result';;
        $results{$hash->{you}}++ if $hash->{you};
        $results{welcome}++ if $hash->{welcome};
        #say "got " . Dumper($hash);
        #$tx->finish;
      });
      $tx->send('hello');
      $tx->send($play);
    });

  }
}

Mojo::IOLoop->timer(5 => sub { shift->stop });
Mojo::IOLoop->start;

say "results : ";
say Dumper(\%results);


