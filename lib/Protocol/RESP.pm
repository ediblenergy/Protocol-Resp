package Protocol::RESP;
use strict;
use warnings;
use Data::Dumper::Concise;
#REdis Serialization Protoco
#http://redis.io/topics/protocol

sub new {
    my($class,$params) = @_;
    $params ||= {};
    my $self = {%$params};
    bless $self, $class;
    return $self;
}

my %type_dispatch = (
    '+' => "simple_string",
    '-' => "error",
    ':' => "integer",
    '$' => "bulk_string",
    '*' => "array",
);
sub array {
    my($self,$num_elements,$text_ref) = @_;
    my $arr = [];
    for( 1 .. $num_elements ) {
        push @$arr,$self->_parse($text_ref);
    }
    return $arr;
}

sub simple_string {
    my($self,$str) = @_;
    return "$str";
}
sub integer {
    my($self,$int) = @_;
    return 0+$int;
}
sub bulk_string {
    my($self,$len,$text_ref) = @_;
    my $str = substr($$text_ref,0,$len,'');
    $$text_ref =~  s/^\r\n//;
    if(length($str) != $len) {
        die "incomplete parse";
    }
    return $str;
}

sub parse {
    my ($self,$str) = @_;
    return $self->_parse(\$str);
}
sub _parse {
    my($self,$text_ref) = @_;
    while($$text_ref =~ s/([^\r]+)\r\n//) {
        my $line = $1;
        my $t = substr( $line, 0, 1, '');
        my $type = $type_dispatch{$t};
        die "cannot handle $t" unless $type;
        return $self->$type($line,$text_ref);
    }
    return;
}

1;
__END__
In RESP, the type of some data depends on the first byte:
For Simple Strings the first byte of the reply is "+"
For Errors the first byte of the reply is "-"
For Integers the first byte of the reply is ":"
For Bulk Strings the first byte of the reply is "$"
For Arrays the first byte of the reply is "*"
