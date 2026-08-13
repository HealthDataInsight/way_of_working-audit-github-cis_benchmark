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

              # Creates or updates the ruleset owned by this rule (identified by
              # `self.class::RULESET_NAME`), so re-running --fix converges an
              # out-of-date ruleset instead of piling up duplicates.
              def apply_ruleset_fix
                repo_name = @repo.full_name
                managed_ruleset = rulesets.find { |ruleset| ruleset[:name] == self.class::RULESET_NAME }

                if managed_ruleset
                  $stdout.puts "Applying fix: Updating ruleset '#{self.class::RULESET_NAME}' on #{repo_name}"
                  @client.patch("/repos/#{repo_name}/rulesets/#{managed_ruleset[:id]}", required_ruleset_config)
                else
                  $stdout.puts "Applying fix: Creating ruleset '#{self.class::RULESET_NAME}' on #{repo_name}"
                  @client.post("/repos/#{repo_name}/rulesets", required_ruleset_config)
                end

                @errors.clear
              rescue Octokit::Error => e
                warn "Failed to apply fix: #{e.class} - #{e.message}"
                warn e.backtrace.join("\n") if ENV['DEBUG']
                @errors << "Failed to apply fix: #{e.message}"
              rescue StandardError => e
                warn "Unexpected error applying fix: #{e.class} - #{e.message}"
                warn e.backtrace.join("\n") if ENV['DEBUG']
                @errors << "Unexpected error applying fix: #{e.message}"
              end
            end
          end
        end
      end
    end
  end
end
