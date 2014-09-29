package Types::Namespace;

use strict;
use warnings;

use Type::Library -base, -declare => qw( Uri Iri Namespace NamespaceMap );
use Types::Standard qw( HashRef InstanceOf );
use Types::URI qw();

our $VERSION = '0.12';

__PACKAGE__->add_type(
	name       => Uri,
	parent     => Types::URI::Uri,
	coercion   => [
		@{ Types::URI::Uri->coercion->type_coercion_map },
		InstanceOf['URI::Namespace'] ,=> q{ $_->uri() },
	],
);

__PACKAGE__->add_type(
	name       => Iri,
	parent     => Types::URI::Iri,
	coercion   => [
		@{ Types::URI::Iri->coercion->type_coercion_map },
		InstanceOf['URI::Namespace'] ,=> q{ $_->iri() },
	],
);

__PACKAGE__->add_type(
	name       => Namespace,
	parent     => InstanceOf['URI::Namespace'],
	coercion   => [
		Iri->coercibles ,=> q{ "URI::Namespace"->new($_) },
	],
);

__PACKAGE__->add_type(
	name       => NamespaceMap,
	parent     => InstanceOf['URI::NamespaceMap'],
	coercion   => [
		HashRef ,=> q{ "URI::NamespaceMap"->new(namespace_map => $_) }
	],
);

require URI::Namespace;
require URI::NamespaceMap;

1;
