package URI::Namespace;
use Moose;
use Moose::Util::TypeConstraints;
use URI;
use IRI;

=head1 NAME

URI::Namespace - A namespace URI class with autoload methods


=head1 SYNOPSIS

  use URI::Namespace;
  my $foaf = URI::Namespace->new( 'http://xmlns.com/foaf/0.1/' );
  print $foaf->as_string;
  print $foaf->name;

=head1 DESCRIPTION

This module provides an object with a URI attribute, typically used
prefix-namespace pairs, typically used in XML, RDF serializations,
etc. The local part can be used as a method, these are autoloaded.

=head1 METHODS

=over

=item C<< new ( $string | URI ) >>

This is the constructor. You may pass a string with a URI or a URI object.

=item C<< uri ( [ $local_part ] ) >>

Returns a L<URI> object with the namespace URI. Optionally, the method
can take a local part as argument, in which case, it will return the
namespace URI with the local part appended.

=back

The following methods from L<URI> can be used on an URI::Namespace object: C<as_string>, C<as_iri>, C<canonical>, C<eq>, C<abs>, C<rel>.

One important usage for this module is to enable you to create L<URI>s for full URIs, e.g.:

  print $foaf->Person->as_string;

will return

  http://xmlns.com/foaf/0.1/Person

=head1 FURTHER DETAILS

See L<URI::NamespaceMap> for further details about authors, license, etc.

=cut

around BUILDARGS => sub {
	my ($next, $self, @parameters) = @_;
	return $self->$next(@_) if ((@parameters > 1) || (ref($parameters[0]) eq 'HASH'));
	return { _uri => $parameters[0] };
};

coerce 'IRI' => from 'Str' => via { IRI->new($_) };

has _uri => ( 
	isa => 'IRI',
	coerce => 1,
	required => 1,
	reader => '_uri',
	handles => ['as_string']
);

# TODO: handle URI methods that IRI doesn't do: as_iri, canonical, eq, abs, rel

sub iri {
	my ($self, $name) = @_;
	if (defined($name)) {
		return IRI->new($self->_uri->as_string . "$name");
	} else {
		return $self->_uri;
	}
}

sub uri {
	my ($self, $name) = @_;
	my $iri	= $self->_uri->as_string;
	if (defined($name)) {
		return URI->new($iri . "$name");
	} else {
		return URI->new($iri);
	}
}

our $AUTOLOAD;
sub AUTOLOAD {
	my $self = shift;
	my ($name) = $AUTOLOAD =~ /::(\w+)$/;
	return $self->uri($name);
}



no Moose::Util::TypeConstraints;
no Moose;

__PACKAGE__->meta->make_immutable();

1;
__END__
