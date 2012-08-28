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
											 list_namespaces => 'values',
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
		$ns	= $self->{ $1 };
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

1;
__END__
