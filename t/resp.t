use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Test::More;
use Protocol::Resp;
my $arr = "*2\r\n\$3\r\nfoo\r\n\$3\r\nbar\r\n";
my $p = Protocol::Resp->new;
my $res = $p->_parse(\$arr);
is_deeply $res,["foo","bar"];
