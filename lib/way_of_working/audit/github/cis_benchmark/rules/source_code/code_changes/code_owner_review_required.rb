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
              # This rule checks that code owner review is required when a change affects owned code.
              class CodeOwnerReviewRequired < ::WayOfWorking::Audit::Github::CisBenchmark::Rules::Base
                include Concerns::RulesetFinder

                RULESET_NAME = 'Way of Working CIS: Code Owner Review Required'

                def tags
                  super << :cis_level1
                end

                def validate
                  existing_rulesets = find_default_branch_rulesets

                  if existing_rulesets.empty?
                    @errors << "No ruleset requiring code owner review on default branch (#{@repo.default_branch})"
                    return apply_ruleset_fix if fix

                    return
                  end

                  return if existing_rulesets.any? { |ruleset| requires_code_owner_review?(ruleset) }

                  @errors << "Code owner review is not required on default branch (#{@repo.default_branch}) - " \
                             "found #{existing_rulesets.size} ruleset(s), none require code owner review"
                  apply_ruleset_fix if fix
                end

                private

                def required_ruleset_config
                  {
                    name: RULESET_NAME,
                    target: 'branch',
                    enforcement: 'active',
                    conditions: default_branch_conditions,
                    rules: [code_owner_review_rule],
                    bypass_actors: []
                  }
                end

                def default_branch_conditions
                  { ref_name: { exclude: [], include: ['~DEFAULT_BRANCH'] } }
                end

                def code_owner_review_rule
                  { type: 'pull_request', parameters: { require_code_owner_review: true } }
                end

                def requires_code_owner_review?(ruleset)
                  return false unless ruleset[:enforcement] == 'active'

                  ruleset[:rules]&.any? do |rule|
                    rule[:type] == 'pull_request' && rule.dig(:parameters, :require_code_owner_review)
                  end
                end
              end
            end
          end
        end
      end

      Rules::Registry.register(CisBenchmark::Rules::SourceCode::CodeChanges::CodeOwnerReviewRequired,
                               "Code owner's review required")
    end
  end
end
