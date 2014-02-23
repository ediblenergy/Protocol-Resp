package Protocol::Resp;
use strict;
use warnings;
use Data::Dumper::Concise;
#http://redis.io/topics/protocol

my ( $text, $ch, $at, $depth, $len );

my @_text;
my $_cur_frame = 0;
sub new {
    my($class,$params) = @_;
    $params ||= {};
    my $self = {%$params};
    bless $self, $class;
    return $self;
}
sub simple_string {
    die;
}
sub integer {
    die;
}
#sub bulk_string {
#    next_chr();
#}

my $tokes = join "" => map { quotemeta($_) } qw[ + - : $ * ];
my $match_type = "[$tokes](\\d+)\$";
sub _num_from_header {
    my $header = shift;
    $header =~ qr/$match_type/;
    my $num = $1 || die "malformed header: $header";
    return 0+$num;
}
#my $arr = "*2\r\n\$3\r\nfoo\r\n\$3\r\nbar\r\n";
#sub array {
#    my $ret = [];
#    my $num_elements = _num_from_header($_text[$_cur_frame]);
#    die $num_elements;
##    for ( my $i = 0 ; $i < $num_elements ; $i++ ) {
##        my ( $size, $content ) =
##          ( _num_from_header( shift(@frame) ), shift(@frame) );
##        die "incorrect length: $size for bytes: $content"
##          unless ( length($content) == $size );
##          push($ret,$content);
##    }
##    return $ret;
#}

sub value {
    my $ch =  substr($_text[$_cur_frame],0,1);
    return                 if ( !defined $ch );
    return simple_string() if ( $ch eq '+' );
    return error()         if ( $ch eq '-' );
    return integer()       if ( $ch eq ':' );
    return bulk_string()   if ( $ch eq '$' );
    return array() if ( $ch eq '*' );
}
sub parse_response {
    my($class,$str) = @_;
    @_text = split "\r\n" => $str;
    warn Dumper \@_text;
    return value();
#    $text = $str;
#    ($at, $ch, $depth) = (0, '', 0);
#    $len = length $text;
#    white();
#    my $result = value();
}
my %dispatch = (
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
        warn Dumper $arr;
    }
    return $arr;
}

sub bulk_string {
    my($self,$len,$text_ref) = @_;
    warn "bulk_string len: $len";
    warn "text_ref: $$text_ref";
    my $str = substr($$text_ref,0,$len,'');
    $$text_ref =~  s/^\r\n//;
    return $str;
}
sub _parse {
    my($self,$text_ref) = @_;
    while($$text_ref =~ s/([^\r]+)\r\n//) {
        my $line = $1;
        my $t = substr( $line, 0, 1, '');
        warn "T: $t";
        my $type = $dispatch{$t};
        warn "Type: $type";
        return $self->$type($line,$text_ref);
    }
    return;
}

sub white {
    while ( defined $ch ) {
        if ( $ch le ' ' ) {
            next_chr();
        } else {
            last;
        }
    }
}
sub next_chr {
    return $ch = undef if($at >= $len);
    $ch = substr($text, $at++, 1);
}
1;
__END__
In RESP, the type of some data depends on the first byte:
For Simple Strings the first byte of the reply is "+"
For Errors the first byte of the reply is "-"
For Integers the first byte of the reply is ":"
For Bulk Strings the first byte of the reply is "$"
For Arrays the first byte of the reply is "*"
