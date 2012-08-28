package URI::Namespace;
use Moose;
use Moose::Util::TypeConstraints;
use URI;

around BUILDARGS => sub {
    my ($next, $self, @parameters) = @_;
    return $self->$next(@_) if ((@parameters > 1) || (ref($parameters[0]) eq 'HASH'));
    return { uri => $parameters[0] };
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

our $AUTOLOAD;
sub AUTOLOAD {
  my $self = shift;
  my ($name) = $AUTOLOAD =~ /::(\w+)$/;
  return URI->new($self->uri . "$name");
}
1;
__END__
