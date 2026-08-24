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
              # This rule checks that a linear history is required on the default branch,
              # preventing merge commits that obscure the commit history.
              class LinearHistoryRequired < ::WayOfWorking::Audit::Github::CisBenchmark::Rules::Base
                include Concerns::RulesetFinder

                RULESET_NAME = 'Way of Working CIS: Linear History Required'

                def tags
                  super << :cis_level1
                end

                def validate
                  existing_rulesets = find_default_branch_rulesets

                  if existing_rulesets.empty?
                    @errors << "No ruleset requiring linear history on default branch (#{@repo.default_branch})"
                    return apply_ruleset_fix if fix

                    return
                  end

                  return if existing_rulesets.any? { |ruleset| linear_history_required?(ruleset) }

                  @errors << "Linear history is not required on default branch (#{@repo.default_branch}) - " \
                             "found #{existing_rulesets.size} ruleset(s), none require linear history"
                  apply_ruleset_fix if fix
                end

                private

                def required_ruleset_config
                  {
                    name: RULESET_NAME,
                    target: 'branch',
                    enforcement: 'active',
                    conditions: default_branch_conditions,
                    rules: [{ type: 'required_linear_history' }],
                    bypass_actors: []
                  }
                end

                def default_branch_conditions
                  { ref_name: { exclude: [], include: ['~DEFAULT_BRANCH'] } }
                end

                def linear_history_required?(ruleset)
                  ruleset_has_rule_type?(ruleset, 'required_linear_history')
                end
              end
            end
          end
        end
      end

      Rules::Registry.register(CisBenchmark::Rules::SourceCode::CodeChanges::LinearHistoryRequired,
                               'Linear history required')
    end
  end
end
