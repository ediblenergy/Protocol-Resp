use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Test::More;
use Protocol::Resp;
my $arr = '*2\r\n$3\r\nfoo\r\n$3\r\nbar\r\n';
my $res = Protocol::Resp->parse_response($arr);
is_deeply $res,["foo","bar"];
