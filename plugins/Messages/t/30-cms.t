
use lib qw( t/lib lib extlib );

use strict;
use warnings;

BEGIN {
    $ENV{MT_APP} = 'MT::App::CMS';
}

use MT::Test qw( :app :db :data );
use Test::More tests => 2;

# need to add some bits to the registry
# let's just use the Messages plugin for now

require MT;
my $p = MT->component('Messages');

my $r = $p->registry;
$r->{messages}->{edit_entry}->{_test_msg} =
  { text => "THIS IS MY TEST MESSAGE" };

# have to re-init the app
require Messages::CMS;
require MT::Callback;
my $cb = MT::Callback->new( { plugin => $p } );
Messages::CMS::init_app( $cb, MT->instance );

require MT::Author;
my $a = MT::Author->load(1);

out_unlike(
    'MT::App::CMS',
    {
        __test_user => $a,
        __mode      => 'view',
        _type       => 'entry',
        id          => 1,
        blog_id     => 1
    },
    qr/THIS IS MY TEST MESSAGE/,
    "Test message does not appear when parameter isn't passed"
);

out_like(
    'MT::App::CMS',
    {
        __test_user => $a,
        __mode      => 'view',
        _type       => 'entry',
        id          => 1,
        blog_id     => 1,
        _test_msg   => 1
    },
    qr/THIS IS MY TEST MESSAGE/,
    "Test message does appear when the parameter *is* present"
);

1;
