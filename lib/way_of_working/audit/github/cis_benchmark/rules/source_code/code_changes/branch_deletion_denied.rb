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
              # This rule checks that branch deletion is denied on the default branch.
              # This prevents accidental or malicious deletion of the protected main branch
              # which can lead to data loss and disruption of development workflows.
              class BranchDeletionDenied < ::WayOfWorking::Audit::Github::CisBenchmark::Rules::Base
                include Concerns::RulesetFinder

                RULESET_NAME = 'Way of Working CIS: Branch Deletion Denied'

                def tags
                  super << :cis_level1
                end

                def validate
                  existing_rulesets = find_default_branch_rulesets

                  if existing_rulesets.empty?
                    @errors << "No ruleset denying branch deletion on default branch (#{@repo.default_branch})"
                    return apply_ruleset_fix if fix

                    return
                  end

                  # Check if any existing ruleset denies branch deletion
                  return unless existing_rulesets.none? { |ruleset| branch_deletion_denied?(ruleset) }

                  @errors << "Branch deletion is not denied on default branch (#{@repo.default_branch}) - " \
                             "found #{existing_rulesets.size} ruleset(s), none deny deletion"
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
                        type: 'deletion'
                      }
                    ],
                    bypass_actors: []
                  }
                end

                def branch_deletion_denied?(existing_ruleset)
                  ruleset_has_rule_type?(existing_ruleset, 'deletion')
                end
              end
            end
          end
        end
      end

      Rules::Registry.register(CisBenchmark::Rules::SourceCode::CodeChanges::BranchDeletionDenied,
                               'Protected (default) branch deletions are denied')
    end
  end
end
