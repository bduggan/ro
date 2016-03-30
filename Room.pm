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
  my $elapsed = abs $played_at{$p1} - $played_at{$p2};
  delete $played{$_} for $p1, $p2;
  delete $played_at{$_} for $p1, $p2;
  return "$p1 vs $p2 took $elapsed seconds";
}

1;
