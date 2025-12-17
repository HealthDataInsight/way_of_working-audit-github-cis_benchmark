# frozen_string_literal: true

module WayOfWorking
  module Audit
    module Github
      module CisBenchmark
        module Rules
          module Concerns
            # Shared concern for finding rulesets by branch pattern
            module RulesetFinder
              private

              # Find all rulesets that target the default branch
              def find_default_branch_rulesets
                find_rulesets_by_ref('~DEFAULT_BRANCH')
              end

              # Find all rulesets that target all branches
              def find_all_branches_rulesets
                find_rulesets_by_ref('~ALL')
              end

              # Find rulesets that include a specific ref pattern
              def find_rulesets_by_ref(ref_pattern)
                rulesets.select do |ruleset|
                  includes = ruleset.dig(:conditions, :ref_name, :include)
                  includes&.include?(ref_pattern)
                end
              end

              # Check if a ruleset has a specific rule type
              def ruleset_has_rule_type?(ruleset, rule_type)
                return false unless ruleset[:enforcement] == 'active'

                ruleset[:rules]&.any? { |rule| rule[:type] == rule_type }
              end
            end
          end
        end
      end
    end
  end
end
