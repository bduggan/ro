package Room;
use Mojo::Base qw/-base/;
use experimental 'signatures';

use Game;

my %partner_for; # $id => $id
my @available;   # array of open games
my %game_of;     # id => $game

sub has_partner($s,$id) {
  return $partner_for{$id};
}

sub _next_available {
    # Really there should only be at most one available game.
    my $next = shift @available or return;
    $next = shift @available while @available && $next->expired;
    return if $next->expired;
    return $next;
}

sub find_game($s,$who,$what) {
  if (my $g = $s->_next_available) {
    return $s->assign($who => $g);
  }
  my $game = Game->new;
  $game->shoot($who => $what);
  push @available, $game;
  $s->assign($who => $game);
  return undef;
}

sub pair_up($s,$one,$two) {
  return if $partner_for{$one};
  return if $partner_for{$two};
  $partner_for{$one} = $two;
  $partner_for{$two} = $one;
  return $s->_pair($one,$two);
}

sub playing($s,$p) {
   my $g = $game_of{$p} or return;
   return $g unless $g->expired;
   $s->leave_game($_) for $g->players;
   return;
}

sub leave_game($s,$p) {
    delete $game_of{$p};
}

sub assign($s,$p,$g) {
    $game_of{$p} = $g;
}

sub available {
  return scalar @available;
}

sub add_game($s,$p,$h,$pair) {
    my $game = Game->new(pair => $pair);
    $game_of{$p} = $game;
    $game->shoot($p => $h);
    $game;
}

{
my $pair_counter = 1;
my %used;
sub _pair($s,$p1,$p2) {
    # new id for p1 + p2
    ($p1,$p2) = ($p2,$p1) if $p2 < $p1;
    $used{$p1,$p2} = $pair_counter++;
}
sub paired($s,$p1,$p2) {
    # find existing pair id for p1 + p2
    ($p1,$p2) = ($p2,$p1) if $p2 < $p1;
    return $used{$p1,$p2};
}
}

1;
