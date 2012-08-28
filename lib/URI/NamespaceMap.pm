package URI::NamespaceMap;
use Moose;
use Moose::Util::TypeConstraints;


=head1 NAME

URI::NamespaceMap - Class holding a collection of namespaces

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

  use URI::NamespaceMap;
  my $map = URI::NamespaceMap->new( { xsd => 'http://www.w3.org/2001/XMLSchema#' } );
  $map->namespace_uri('xsd')->as_string;
  my $foaf = URI::Namespace->new( 'http://xmlns.com/foaf/0.1/' );
  $map->add_mapping(foaf => $foaf);
  $map->add_mapping(rdf => 'http://www.w3.org/1999/02/22-rdf-syntax-ns#' );
  $map->list_prefixes;  #  ( 'foaf', 'rdf', 'xsd' )


=head1 DESCRIPTION

This module provides an object to manage multiple namespaces for creating L<URI::Namespace> objects and for serializing.

=head1 METHODS



=cut


around BUILDARGS => sub {
  my ($next, $self, @parameters) = @_;
  return $self->$next(@parameters) if (@parameters > 1);
  return $self->$next(@parameters) if (exists $parameters[0]->{namespace_map});
  return { namespace_map => $parameters[0] };
};

subtype NamespaceMap => as HashRef => where { 
    my $h = $_;  
    return 1 unless values %$h; 
    return if grep { !blessed $_ } values %$h; 
    return 1
};
coerce NamespaceMap => from HashRef => via {
    my $hash = $_;
    return {
         map {
	      my $k = $_;
              my $v = $hash->{$_}; 
              $k => blessed $v ? $v : URI::Namespace->new($v) 
         } keys %$hash
    };
};

has namespace_map => (
    isa => 'NamespaceMap',
    traits => ['Hash'],
    coerce => 1,
    default => sub { {} },
    handles => {
         add_mapping => 'set',
         remove_mapping => 'delete',
	 namespace_uri => 'get',
	 list_namespaces => 'values',
         list_prefixes => 'keys',
   }
);

=over

=item C<< uri ( $prefixed_name ) >>

Returns a URI for an abbreviated string such as 'foaf:Person'.

=back

=cut

sub uri {
	my $self	= shift;
	my $abbr	= shift;
	my $ns;
	my $local	= "";
	if ($abbr =~ m/^([^:]*):(.*)$/) {
		$ns	= $self->namespace_uri( $1 );
		$local	= $2;
	} else {
		$ns	= $self->{ $abbr };
	}
	return unless (blessed($ns));
	if ($local ne '') {
		return $ns->$local();
	} else {
		return $ns->as_string;
	}
}

our $AUTOLOAD;
sub AUTOLOAD {
    my $self = shift;
    my ($name) = ($AUTOLOAD =~ /::(\w+)$/);
    $self->namespace_uri($name);
}

1;
__END__
