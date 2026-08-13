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
              # This rule checks that previous approvals are dismissed when updates are introduced to
              # a code change proposal.
              class PreviousPrApprovalsDismissed < ::WayOfWorking::Audit::Github::CisBenchmark::Rules::Base
                include Concerns::RulesetFinder

                RULESET_NAME = 'Way of Working CIS: Previous PR Approvals Dismissed'

                def tags
                  super << :cis_level1
                end

                def validate
                  existing_rulesets = find_default_branch_rulesets

                  if existing_rulesets.empty?
                    @errors << "No ruleset dismissing stale PR approvals on default branch (#{@repo.default_branch})"
                    return apply_ruleset_fix if fix

                    return
                  end

                  return if existing_rulesets.any? { |ruleset| dismisses_stale_approvals?(ruleset) }

                  @errors << "Previous PR approvals are not dismissed on default branch (#{@repo.default_branch}) - " \
                             "found #{existing_rulesets.size} ruleset(s), none dismiss stale approvals"
                  apply_ruleset_fix if fix
                end

                private

                def required_ruleset_config
                  {
                    name: RULESET_NAME,
                    target: 'branch',
                    enforcement: 'active',
                    conditions: {
                      ref_name: {
                        exclude: [],
                        include: ['~DEFAULT_BRANCH']
                      }
                    },
                    rules: [
                      {
                        type: 'pull_request',
                        parameters: {
                          dismiss_stale_reviews_on_push: true
                        }
                      }
                    ],
                    bypass_actors: []
                  }
                end

                def dismisses_stale_approvals?(ruleset)
                  return false unless ruleset[:enforcement] == 'active'

                  ruleset[:rules]&.any? do |rule|
                    rule[:type] == 'pull_request' && rule.dig(:parameters, :dismiss_stale_reviews_on_push)
                  end
                end
              end
            end
          end
        end
      end

      Rules::Registry.register(CisBenchmark::Rules::SourceCode::CodeChanges::PreviousPrApprovalsDismissed,
                               '1.1.4 Previous PR approvals dismissed')
    end
  end
end
