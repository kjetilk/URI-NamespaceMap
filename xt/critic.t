use Test::Perl::Critic(-exclude => [
											  'RequireExtendedFormatting',
											  'ProhibitComplexMappings',
											  'ProhibitAutoloading'],
							  -severity => 3);
all_critic_ok();
