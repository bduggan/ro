package Game;
use Mojo::Base qw/-base/;
use Time::HiRes qw/time/;
use v5.20;
use experimental 'signatures';

our $Timeout = 2;  # Games expire after 2 seconds.

# p1, p2: player 1,2 hand 1,2
has 'id' => sub { state $i; ++$i; };
has 'played'  => sub { +{} }; # p1 -> h1, p2 -> h2
has 'times'   => sub { +{} }; # p1 -> t1, p2 -> t2
has 'winner';  # rock|scissors|paper|tie
has 'pair';    # unique id for this pair of players

# All set?
sub set($g) {
    return $g->players == 2;
}

# Shoot!
sub shoot($g, $us, $ours) {
  $g->played->{$us} = $ours;
  $g->times->{$us} = time;
  return unless $g->set;

  my %better_than = ( rock => 'scissors', paper => 'rock', 'scissors' => 'paper' );
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

sub summary($g) {
    my ($p1,$p2) = $g->players;
    return sprintf("game %d: %d vs %d, %s vs %s (%s) elapsed: %0.6f",
        $g->id, $p1, $p2, $g->{played}{$p1}, $g->{played}{$p2}, $g->winner, $g->elapsed
    );
}

sub elapsed($g) {
   my ($t1,$t2) = values %{ $g->times };
   return abs($t2 - $t1);
}

sub expired($g) {
    my @times = values %{ $g->times };
    return 0 if @times==2;
    my $diff = time - $times[0];
    return $diff > $Timeout;
}

1;

