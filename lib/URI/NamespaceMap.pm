package URI::NamespaceMap;
use Moose;
use Moose::Util::TypeConstraints;

around BUILDARGS => sub {
  my ($next, $self, @parameters) = @_;
  return $self->$next(@parameters) if (@parameters > 1);
  return $self->$next(@parameters) if (exists $parameters[0]->{namespace_map});
  return { namespace_map => $parameters[0] };
};

subtype NamespaceMap => as HashRef => where { my $h = $_;  return 1 unless values %$h; return if grep { !blessed $_ } values %$h; return 1 };
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
