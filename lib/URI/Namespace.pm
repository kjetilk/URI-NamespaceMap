package URI::Namespace;
use Moose;

around BUILDARGS {
    my ($n, $s, @a) = @_;
    return $s->$n(@_) if @a > 1 || ref(@a) eq 'HASH';
    return { uri => $a[0] };
}

has uri => ( 
    is => 'ro', 
    isa => 'Str', 
    required => 1
);

sub as_string { shift->uri }

1;
__END__
