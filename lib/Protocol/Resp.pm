use strict;
use warnings;
package Protocol::Resp;
#http://redis.io/topics/protocol

my %dispatch = (
    '+' => "simple_string",
    '-' => "error",
    ':' => "integer",
    '$' => "bulk_string",
    '*' => "array",
);
sub _parse_array {
    my($class,$str_ref) = @_;
    $$str_ref =~ /^(\d+)\r\n/;
    my $num_elements = $1;
    warn $num_elements;
    warn $$str_ref;
    return []
}

sub parse_response {
    my($class,$str) = @_;
    my $type = substr($str,0,1,'');
    my $meth = sprintf "_parse_%s",$dispatch{$type};
    return $class->$meth(\$str);
}
1;
__END__
In RESP, the type of some data depends on the first byte:
For Simple Strings the first byte of the reply is "+"
For Errors the first byte of the reply is "-"
For Integers the first byte of the reply is ":"
For Bulk Strings the first byte of the reply is "$"
For Arrays the first byte of the reply is "*"
