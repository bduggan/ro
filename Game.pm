package Game;
use Mojo::Base qw/-base/;
use Time::HiRes qw/time/;
use v5.20;
use experimental 'signatures';

has 'id' => sub { state $i; ++$i; };

# player 1,2 hand 1,2
has 'played'  => sub { +{} }; # p1 -> h1, p2 -> h2
has 'times'   => sub { +{} }; # p1 -> t1, p2 -> t2
has 'winner';  # rock|scissors|paper|tie

has 'log';

# All set?
sub set($g) {
    return $g->players == 2;
}

# Shoot!
sub shoot($g, $us, $ours) {
  $g->{played}{$us} = $ours;
  my %better_than = ( rock => 'scissors', paper => 'rock', 'scissors' => 'paper' );
  die "not enough players" unless $g->set;
  my ($one,$two) = values %{ $g->played };
  my $winner =
      $better_than{$one} eq $two ? $one
    : $better_than{$two} eq $one ? $two
    : 'tie';
  $g->winner($winner);
}

sub players($g) {
    return keys %{ $g->{played} };
}

sub other_player($g,$p) {
    my ($other) = grep { $_ != $p } $g->players;
    return $other;
}

1;

