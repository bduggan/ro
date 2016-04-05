package Room;
use Mojo::Base 'Mojo::EventEmitter';
use Time::HiRes qw/time/;
use experimental 'signatures';

use Game;

has 'log';

# events:
# seek => $id => rock|paper|scissors
# play_by:$id => rock|paper|scissors

my %partner_for; # $id => $id
#my %played;      # $id => rock|paper|scissors
#my %played_at;   # $id => timestamp
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
  $s->emit(seek => $who => $game);
  return undef;
}

sub pair_up($s,$one,$two) {
  return if $partner_for{$one};
  return if $partner_for{$two};
  $partner_for{$one} = $two;
  $partner_for{$two} = $one;
}

# sub played($s,$id) {
#   return $played{$id};
# }
#
# sub reveal($s,$id,$what) {
#   warn "$id already played" if $played{$id};
#   $played{$id} = $what;
#   $played_at{$id} = time;
#   $s->emit("play_by:$id" => $what);
# }
#
# sub game_over($s,$p1,$p2) {
#   $game_time{$game_id} //= abs $played_at{$p1} - $played_at{$p2};
#   $game_id++;
#   $s->log->debug("game $game_id: $p1 vs $p2 took $elapsed seconds");
#   return $game_id;
# }
#
#
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
