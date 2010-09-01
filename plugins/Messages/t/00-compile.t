
use lib qw( t/lib lib extlib );

use strict;
use warnings;

use MT::Test;
use Test::More tests => 2;

require MT;

ok(MT->component('Messages'), "Plugin installed successfully");
require_ok('Messages::CMS');

1;
