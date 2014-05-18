use Test::Perl::Critic(-exclude => [
											  'RequireExtendedFormatting',
											  'ProhibitComplexMappings',
											  'ProhibitAutoloading',
											  'ProhibitCascadingIfElse',
											  'RequireCarping'],
							  -severity => 3);
all_critic_ok();
