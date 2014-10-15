use Test::Perl::Critic(-exclude => [
											  'RequireExtendedFormatting',
											  'ProhibitAutoloading',
											  'ProhibitCascadingIfElse',
											  'RequireCarping',
											  'RequireFinalReturn',
											  'RequireArgUnpacking',
											  'RequireCheckingReturnValueOfEval',
											  'ProhibitStringyEval'
											  ],
							  -severity => 3);
all_critic_ok();
