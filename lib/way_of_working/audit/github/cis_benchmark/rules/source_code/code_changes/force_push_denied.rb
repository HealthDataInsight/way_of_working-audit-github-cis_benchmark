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
              # This rule checks that force push to all branches is denied.
              # This prevents rewriting git history which can cause issues with
              # code traceability and audit trails.
              class ForcePushDenied < ::WayOfWorking::Audit::Github::CisBenchmark::Rules::Base
                include Concerns::RulesetFinder

                def tags
                  super << :cis_level1
                end

                def validate
                  existing_rulesets = find_all_branches_rulesets

                  if existing_rulesets.empty?
                    @errors << 'No ruleset denying force push to all branches'
                    return apply_fix if fix

                    return
                  end

                  # Check if any existing ruleset denies force push
                  return unless existing_rulesets.none? { |ruleset| force_push_denied?(ruleset) }

                  @errors << "Force push is not denied on all branches " \
                             "(found #{existing_rulesets.size} ruleset(s), none deny force push)"
                  apply_fix if fix
                end

                def apply_fix
                  repo_name = @repo.full_name
                  $stdout.puts "Applying fix: Creating force push prevention ruleset on #{repo_name}"

                  # Use the GitHub API to create the ruleset
                  response = @client.post("/repos/#{repo_name}/rulesets", required_ruleset_config)
                  $stdout.puts "Successfully created ruleset: #{response[:name]} (ID: #{response[:id]})"

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

                private

                def required_ruleset_config
                  {
                    name: 'Way of Working CIS Force Push Prevention',
                    target: 'branch',
                    enforcement: 'active',
                    conditions: {
                      ref_name: {
                        exclude: [],
                        include: ['~ALL']
                      }
                    },
                    rules: [
                      {
                        type: 'non_fast_forward'
                      }
                    ],
                    bypass_actors: []
                  }
                end

                def force_push_denied?(existing_ruleset)
                  ruleset_has_rule_type?(existing_ruleset, 'non_fast_forward')
                end
              end
            end
          end
        end
      end

      Rules::Registry.register(CisBenchmark::Rules::SourceCode::CodeChanges::ForcePushDenied,
                               'Force push code to branches is denied')
    end
  end
end
