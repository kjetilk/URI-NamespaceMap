package URI::NamespaceMap;
use Moose;
use Moose::Util::TypeConstraints;
use URI::Namespace;


=head1 NAME

URI::NamespaceMap - Class holding a collection of namespaces

=head1 VERSION

Version 0.06

=cut

our $VERSION = '0.06';


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

=item C<< new ( [ \%namespaces ] ) >>

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

=item prefix_for C<< uri ($uri) >>

Returns the associated prefix (or potentially multiple prefixes, when
called in list context) for the given URI.

=cut


# turn the URI back into a string to mitigate unexpected behaviour
sub _scrub_uri {
    my $uri = shift;
    if (ref $uri) {
        if (blessed $uri) {
            if ($uri->isa('URI::Namespace')) {
                $uri = $uri->as_string;
            }
            elsif ($uri->isa('URI')) {
                # it's probably not necessary to do this, but whatever
                $uri = $uri->as_string;
            }
            elsif ($uri->isa('RDF::Trine::Node')) {
                # it is, on the other hand, necessary to do this.
                $uri = $uri->uri_value;
            }
            elsif ($uri->isa('RDF::Trine::Namespace')) {
                # and this
                $uri = $uri->uri->uri_value;
            }
            else {
                # let's hope whatever was passed in has a string overload
                $uri = "$uri";
            }
        }
        else {
            Carp::croak(sprintf "You probably didn't mean to pass this " .
                            "an unblessed %s reference", ref $uri);
        }
    }

    return $uri;
}

sub prefix_for {
    my ($self, $uri) = @_;

    $uri = _scrub_uri($uri);

    my @candidates;
    for my $k ($self->list_prefixes) {
        my $v = $self->namespace_uri($k);

        my $nsuri = $v->as_string;

        # the input should always be longer than the namespace
        next if length $nsuri > length $uri;

        # candidate namespace must match exactly
        my $cns = substr($uri, 0, length $nsuri);
        push @candidates, $k if $cns eq $nsuri;
    }

    # make sure this behaves correctly when empty
    return unless @candidates;

    # if this returns more than one prefix, take the
    # shortest/lexically lowest one.
    @candidates = sort @candidates;

    return wantarray ? @candidates : $candidates[0];
}

=item abbreviate C<< uri ($uri) >>

Complement to L</namespace_uri>. Returns the given URI in C<foo:bar>
format or C<undef> if it wasn't matched, therefore the idiom

    my $str = $nsmap->abbreviate($uri_node) || $uri->as_string;

may be useful for certain serialization tasks.

=cut

sub abbreviate {
    my ($self, $uri) = @_;

    $uri = _scrub_uri($uri);

    my $prefix = $self->prefix_for($uri);

    # XXX is this actually the most desirable behaviour?
    return unless defined $prefix;

    my $nsuri = _scrub_uri($self->namespace_uri($prefix));

    return sprintf('%s:%s', $prefix, substr($uri, length $nsuri));
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


=back

=head1 WARNING

Avoid using the names 'can', 'isa', 'VERSION', and 'DOES' as namespace
prefix, because these names are defined as method for every Perl
object by default. The method names 'new' and 'uri' are also
forbidden. Names of methods of L<Moose::Object> must also be avoided.

=head1 AUTHORS

Chris Prather, C<< <chris@prather.org> >>
Kjetil Kjernsmo, C<< <kjetilk@cpan.org> >>
Gregory Todd Williams, C<< <gwilliams@cpan.org> >>

=head1 CONTRIBUTORS

Dorian Taylor

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

