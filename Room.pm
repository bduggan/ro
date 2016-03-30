package Room;
use Mojo::Base 'Mojo::EventEmitter';
use experimental 'signatures';

# events:
# unpaired_player => $id => rock|paper|scissors
# play_by:$id => rock|paper|scissors

my %partner_for; # $id => $id
my %played;      # $id => rock|paper|scissors

sub has_partner($s,$id) {
  return $partner_for{$id};
}

sub enter($s,$who,$what) {
  $s->emit(unpaired_player => $who, $what);
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

sub play($s,$id,$what) {
  warn "$id already played" if $played{$id};
  $played{$id} = $what;
  $s->emit("play_by:$id" => $what);
}

sub game_over($s,$p1,$p2) {
  delete $played{$_} for $p1, $p2;
}

1;
