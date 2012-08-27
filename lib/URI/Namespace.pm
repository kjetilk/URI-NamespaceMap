package URI::Namespace;
use Moose;
use Moose::Util::TypeConstraints;
use URI;

around BUILDARGS {
    my ($n, $s, @a) = @_;
    return $s->$n(@_) if @a > 1 || ref($a[0]) eq 'HASH';
    return { uri => $a[0] };
}

class_type 'URI';

coerce 'URI' => from 'Str' => via { URI->new($_) };

has uri => ( 
    is => 'ro', 
    isa => 'URI', 
	 coerce => 1,
    required => 1
);

sub as_string { shift->uri }

1;
__END__
