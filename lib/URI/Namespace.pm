package URI::Namespace;
use Moose;
use URI;

around BUILDARGS {
    my ($n, $s, @a) = @_;
    return $s->$n(@_) if @a > 1 || ref($a[0]) eq 'HASH';
    return { uri => $a[0] };
}

has uri => ( 
    is => 'ro', 
    isa => 'URI', 
    required => 1
);

sub as_string { shift->uri }

1;
__END__
