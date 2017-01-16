use Test::Perl::Critic(-exclude => [
											  'ProhibitExcessComplexity',
											  'RequireExtendedFormatting',
											  'ProhibitAutoloading',
											  'ProhibitCascadingIfElse',
											  'RequireFinalReturn',
											  'RequireArgUnpacking',
											  'RequireCheckingReturnValueOfEval',
											  'ProhibitStringyEval'
											  ],
							  -severity => 3);
all_critic_ok();
