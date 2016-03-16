#!perl

use Test::More;
use Test::Mojo;

require 'ro';

my $t = Test::Mojo->new;

# One player.
$t->get_ok('/ready')->status_is(200)->json_is({welcome => 1});
$t->post_ok('/set')->status_is(200)->json_is({ players => 1 });
$t->post_ok('/go' => json => { choice => 'rock' } )
  ->status_is(200)
  ->json_is({outcome => 'mu'});

done_testing();

