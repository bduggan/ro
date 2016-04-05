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

sub want_game($s,$who,$what) {
  if (@available) {
    return $s->assign($who => shift @available);
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
}

sub playing($s,$p) {
   return $game_of{$p};
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

sub add_game($s,$p,$h) {
    my $game = Game->new;
    $game_of{$p} = $game;
    $game->shoot($p => $h);
    $game;
}

1;
