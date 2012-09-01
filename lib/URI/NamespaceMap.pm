package URI::NamespaceMap;
use Moose;
use Moose::Util::TypeConstraints;
use Module::Load::Conditional qw[can_load];
use URI::Namespace;
use Carp;

=head1 NAME

URI::NamespaceMap - Class holding a collection of namespaces

=head1 VERSION

Version 0.03_1

=cut

our $VERSION = '0.03_1';


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

=over

=item C<< new ( [ \%namespaces | @prefixes | @uris ] ) >>

Returns a new namespace map object. You can pass a hash reference with
mappings from local names to namespace URIs (given as string or
L<RDF::Trine::Node::Resource>) or namespaces_map with a hashref.


=item C<< add_mapping ( $name => $uri ) >>

Adds a new namespace to the map. The namespace URI can be passed
as string or a L<URI::Namespace> object.

=item C<< remove_mapping ( $name ) >>

Removes a namespace from the map given a prefix.

=item C<< namespace_uri ( $name ) >>

Returns the namespace object (if any) associated with the given prefix.

=item C<< list_namespaces >>

Returns an array of L<URI::Namespace> objects with all the namespaces.

=item C<< list_prefixes >>

Returns an array of prefixes.

=cut


around BUILDARGS => sub {
	my ($next, $self, @parameters) = @_;
	if (ref($parameters[0]) eq 'ARRAY') {
		return { namespace_map => $self->_guess(@{$parameters[0]}) };
	}
	return $self->$next(@parameters) if (@parameters > 1);
	return $self->$next(@parameters) if (exists $parameters[0]->{namespace_map});
	return { namespace_map => $parameters[0] };
};

subtype 'URI::NamespaceMap::Type::NamespaceMap' => as 'HashRef' => where { 
	my $h = $_;  
	return 1 unless values %$h; 
	return if grep { !blessed $_ } values %$h; 
	return 1
};
coerce 'URI::NamespaceMap::Type::NamespaceMap' => from 'HashRef' => via {
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
							 isa => 'URI::NamespaceMap::Type::NamespaceMap',
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



=item C<< uri ( $prefixed_name ) >>

Returns a URI for an abbreviated string such as 'foaf:Person'.

=back

=cut

sub uri {
	my $self = shift;
	my $abbr = shift;
	my $ns;
	my $local = "";
	if ($abbr =~ m/^([^:]*):(.*)$/) {
		$ns = $self->namespace_uri( $1 );
		$local = $2;
	} else {
		$ns = $self->{ $abbr };
	}
	return unless (blessed($ns));
	if ($local ne '') {
		return $ns->$local();
	} else {
		return $ns->uri
	}
}

no Moose::Util::TypeConstraints;

our $AUTOLOAD;
sub AUTOLOAD {
	my ($self, $arg) = @_;
	my ($name) = ($AUTOLOAD =~ /::(\w+)$/);
	my $ns = $self->namespace_uri($name);
	return unless $ns;
	return $ns->$arg if $arg;
	return $ns;
}

sub _guess {
	my ($self, @data) = @_;
	my $xmlns = can_load( modules => { 'XML::CommonNS' => 0 } );
	my $rdfns = can_load( modules => { 'RDF::NS' => 0 } );
	my $rdfpr = can_load( modules => { 'RDF::Prefixes' => 0 } );

	confess 'To resolve an array, you need either XML::CommonNS, RDF::NS or RDF::Prefixes' unless ($xmlns || $rdfns || $rdfpr);
	my %namespaces;

	foreach my $entry (@data) {
		if ($entry =~ m/^[a-z]\w+/i) {
			# This is a prefix
			carp "Cannot resolve '$entry' without XML::CommonNS or RDF::NS" unless ($xmlns || $rdfns);
			if ($xmlns) {
				use XML::CommonNS ':all';
				$namespaces{$entry} = XML::CommonNS->uri(uc($entry))->toString;
			}
			if ((! $namespaces{$entry}) && $rdfns) {
				my $ns = RDF::NS->new;
				$namespaces{$entry} = $ns->SELECT($entry);
			}
			carp "Cannot resolve '$entry'" unless $namespaces{$entry};
		} else {
			# Lets assume a URI string
			carp "Cannot resolve '$entry' without RDF::NS or RDF::Prefixes" unless ($rdfns || $rdfpr);
			my $prefix;
			if ($rdfns) {
				my $ns = RDF::NS->new;
				$prefix = $ns->PREFIX($entry);
			}
			if ((! $prefix) && ($rdfpr)) {
				my $context = RDF::Prefixes->new;
				$prefix = $context->get_prefix($entry);
			}
			unless ($prefix) {
				carp "Cannot resolve '$entry'";
			} else {
				$namespaces{$prefix} = $entry;
			}
		}
	}
	return \%namespaces;
}


=head1 WARNING

Avoid using the names 'can', 'isa', 'VERSION', and 'DOES' as namespace
prefix, because these names are defined as method for every Perl
object by default. The method names 'new' and 'uri' are also
forbidden. Names of methods of L<Moose::Object> must also be avoided.

=head1 AUTHORS

Chris Prather, C<< <chris@prather.org> >>
Kjetil Kjernsmo, C<< <kjetilk@cpan.org> >>
Gregory Todd Williams, C<< <gwilliams@cpan.org> >>

=head1 BUGS

Please report any bugs using L<github|https://github.com/kjetilk/URI-NamespaceMap/issues>


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc URI::NamespaceMap

=head1 COPYRIGHT & LICENSE

Copyright 2012 Gregory Todd Williams, Chris Prather and Kjetil Kjernsmo

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

__PACKAGE__->meta->make_immutable();

1;
__END__

