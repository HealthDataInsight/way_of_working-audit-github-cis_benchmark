# frozen_string_literal: true

require 'way_of_working/audit/github/cis_benchmark/rules/base'
require 'way_of_working/audit/github/cis_benchmark/rules/concerns/ruleset_finder'

module WayOfWorking
  module Audit
    # This is the namespace for the GitHub audit
    module Github
      module CisBenchmark
        module Rules
          module SourceCode
            module CodeChanges
              # This rule checks that all open review conversations must be resolved
              # before a code change can be merged.
              class ResolveConversationsBeforeMerge < ::WayOfWorking::Audit::Github::CisBenchmark::Rules::Base
                include Concerns::RulesetFinder

                RULESET_NAME = 'Way of Working CIS: Resolve Conversations Before Merge'

                def tags
                  super << :cis_level1
                end

                def validate
                  existing_rulesets = find_default_branch_rulesets

                  if existing_rulesets.empty?
                    @errors << 'No ruleset requiring resolved conversations on default branch ' \
                               "(#{@repo.default_branch})"
                    return apply_ruleset_fix if fix

                    return
                  end

                  return if existing_rulesets.any? { |ruleset| requires_resolved_conversations?(ruleset) }

                  @errors << 'Open conversations are not required to be resolved on default branch ' \
                             "(#{@repo.default_branch}) - found #{existing_rulesets.size} ruleset(s), " \
                             'none require resolution'
                  apply_ruleset_fix if fix
                end

                private

                def required_ruleset_config
                  {
                    name: RULESET_NAME,
                    target: 'branch',
                    enforcement: 'active',
                    conditions: default_branch_conditions,
                    rules: [resolve_conversations_rule],
                    bypass_actors: []
                  }
                end

                def default_branch_conditions
                  { ref_name: { exclude: [], include: ['~DEFAULT_BRANCH'] } }
                end

                # GitHub's ruleset API requires the full pull_request parameter set on creation,
                # not just the property this rule cares about.
                def resolve_conversations_rule
                  {
                    type: 'pull_request',
                    parameters: {
                      required_approving_review_count: 0,
                      dismiss_stale_reviews_on_push: false,
                      require_code_owner_review: false,
                      require_last_push_approval: false,
                      required_review_thread_resolution: true
                    }
                  }
                end

                def requires_resolved_conversations?(ruleset)
                  return false unless ruleset[:enforcement] == 'active'

                  ruleset[:rules]&.any? do |rule|
                    rule[:type] == 'pull_request' && rule.dig(:parameters, :required_review_thread_resolution)
                  end
                end
              end
            end
          end
        end
      end

      Rules::Registry.register(CisBenchmark::Rules::SourceCode::CodeChanges::ResolveConversationsBeforeMerge,
                               'Resolve conversations before merge')
    end
  end
end
