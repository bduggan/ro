package Room;
use Mojo::Base 'Mojo::EventEmitter';
use Time::HiRes qw/time/;
use experimental 'signatures';

# events:
# seek => $id => rock|paper|scissors
# play_by:$id => rock|paper|scissors

my %partner_for; # $id => $id
my %played;      # $id => rock|paper|scissors
my %played_at;   # $id => timestamp
my $game_id = 0; # autoincrement game id

has 'log';

sub has_partner($s,$id) {
  return $partner_for{$id};
}

sub enter($s,$who,$what) {
  $s->reveal($who, $what);
  $s->emit(seek => $who, $what);
}

sub pair_up($s,$one,$two) {
  return if $partner_for{$one};
  return if $partner_for{$two};
  $partner_for{$one} = $two;
  $partner_for{$two} = $one;
}

sub played($s,$id) {
  return $played{$id};
}

sub reveal($s,$id,$what) {
  warn "$id already played" if $played{$id};
  $played{$id} = $what;
  $played_at{$id} = time;
  $s->emit("play_by:$id" => $what);
}

sub game_over($s,$p1,$p2) {
  for ($p1,$p2) {
    next if $played_at{$_} && $played{$_};
    $s->log->debug("no timestamp for $_, invalid game");
    return -1;
  }
  if (exists $game_time{$game_id}) {
    delete $played{$p1};
    delete $played_at{$p1};
  } else {
    $game_time{$game_id} //= abs $played_at{$p1} - $played_at{$p2};
  }
  $game_id++;
  $s->log->debug("game $game_id: $p1 vs $p2 took $elapsed seconds");
  return $game_id;
}

sub playing($s,$p) {
  return exists($played{$p});
}

1;
