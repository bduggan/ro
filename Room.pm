package Room;
use Mojo::Base 'Mojo::EventEmitter';
use experimental 'signatures';

# events:
# unpaired_player => $id => rock|scissors|paper
# play_by:$id => rock|scissors|paper

my %partner_for; # $id => $id

sub has_partner($s,$id) {
  return $partner_for{$id};
}

sub enter($s,$who, $what) {
  $s->emit(unpaired_player => $who, $what);
}

sub pair_up($s,$one,$two) {
  $partner_for{$one} = $two;
  $partner_for{$two} = $one;
}

1;
