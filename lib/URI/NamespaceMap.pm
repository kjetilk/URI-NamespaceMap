package URI::NamespaceMap;
use Moose;

has namespace_map => (
    isa => 'HashRef',
    traits => ['Hash'],
    default => sub { {} },
    handles => {
        add_mapping => 'set',
	remove_mapping => 'delete',
	namespace_uri => 'get',
    }
)

sub uri { 
    my $self = shift;
    URI::Namespace->new($self->get(@_));
}

1;
__END__
