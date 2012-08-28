package URI::Namespace;
use Moose;
use Moose::Util::TypeConstraints;
use URI;

around BUILDARGS => sub {
    my ($ns, $self, @attributes) = @_;
#    return $self->$ns(@_) if ((@attributes > 1) || (ref($attributes[0]) eq 'HASH'));
    return { uri => $attributes[0] };
};

class_type 'URI';

coerce 'URI' => from 'Str' => via { URI->new($_) };

has uri => ( 
    is => 'ro', 
    isa => 'URI', 
	 coerce => 1,
    required => 1,
	 handles => ['as_string']
);


1;
__END__
