package URI::NamespaceMap;
use strict;
use warnings;
use Moo 1.006000;
use Module::Load::Conditional qw[can_load];
use URI::Namespace;
use Carp;
use Scalar::Util qw( blessed );
use Sub::Quote qw( quote_sub );
use Try::Tiny;
use Types::Standard qw(HashRef);
use Types::Namespace 0.004 qw(Namespace);
use namespace::autoclean;

=head1 NAME

URI::NamespaceMap - Class holding a collection of namespaces

=head1 VERSION

Version 0.22

=cut

our $VERSION = '0.22';


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
L<RDF::Trine::Node::Resource>) or namespaces_map with a hashref. You
may also pass an arrayref containing just prefixes and/or namespace URIs,
and the module will try to guess the missing part. To use this
feature, you need L<RDF::NS>, L<XML::CommonNS> or L<RDF::Prefixes>, or
preferably all of them.


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

has namespace_map => (
							 is => "ro",
							 isa => HashRef[Namespace],
							 coerce => 1,
							 default => quote_sub q { {} },
							);

sub add_mapping     { $_[0]->namespace_map->{$_[1]} = Namespace->assert_coerce($_[2]) }
sub remove_mapping  { delete $_[0]->namespace_map->{$_[1]} }
sub namespace_uri   { $_[0]->namespace_map->{$_[1]} }
sub list_namespaces { values %{ $_[0]->namespace_map } }
sub list_prefixes   { keys   %{ $_[0]->namespace_map } }

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
		return $ns->uri($local);
	} else {
		return URI->new($ns->as_string);
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
	my $rdfns = can_load( modules => { 'RDF::NS' => 20130802 } );
	my $rdfpr = can_load( modules => { 'RDF::Prefixes' => 0 } );

	confess 'To resolve an array, you need either XML::CommonNS, RDF::NS or RDF::Prefixes' unless ($xmlns || $rdfns || $rdfpr);
	my %namespaces;

	foreach my $entry (@data) {

		if ($entry =~ m/^[a-z]\w+$/i) {
			# This is a prefix
			warn "Cannot resolve '$entry' without XML::CommonNS or RDF::NS" unless ($xmlns || $rdfns);
			if ($xmlns) {
			  require XML::CommonNS;
			  XML::CommonNS->import(':all');
			  try {
				 $namespaces{$entry} = XML::CommonNS->uri(uc($entry))->toString;
			  }; # Then, XML::CommonNS doesn't have the prefix, which is OK, we just continue
			}
			if ((! $namespaces{$entry}) && $rdfns) {
				my $ns = RDF::NS->new;
				$namespaces{$entry} = $ns->SELECT($entry);
			}
			warn "Cannot resolve '$entry'" unless $namespaces{$entry};
		} else {
			# Lets assume a URI string
			warn "Cannot resolve '$entry' without RDF::NS or RDF::Prefixes" unless ($rdfns || $rdfpr);
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
				warn "Cannot resolve '$entry'";
			} else {
				$namespaces{$prefix} = $entry;
			}
		}
	}
	return \%namespaces;
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
Toby Inkster, C<< <tobyink@cpan.org> >>

=head1 CONTRIBUTORS

Dorian Taylor

=head1 BUGS

Please report any bugs using L<github|https://github.com/kjetilk/URI-NamespaceMap/issues>


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc URI::NamespaceMap

=head1 COPYRIGHT & LICENSE

Copyright 2012-2014 Gregory Todd Williams, Chris Prather and Kjetil Kjernsmo

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

__PACKAGE__->meta->make_immutable();

1;
__END__

