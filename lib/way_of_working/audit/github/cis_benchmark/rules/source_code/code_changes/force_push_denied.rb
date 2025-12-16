# frozen_string_literal: true

require 'way_of_working/audit/github/cis_benchmark/rules/base'

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
                def tags
                  super << :cis_level1
                end

                def validate
                  existing_ruleset = find_all_branches_ruleset

                  unless existing_ruleset
                    @errors << "No ruleset denying force push to all branches"
                    return apply_fix if fix
                    return
                  end

                  # Check if the existing ruleset denies force push
                  unless force_push_denied?(existing_ruleset)
                    @errors << "Force push is not denied on all branches"
                    return apply_fix if fix
                  end
                end

                def apply_fix
                  repo_name = @repo.full_name
                  $stdout.puts "Applying fix: Creating force push prevention ruleset on #{repo_name}"

                  # Use the GitHub API to create the ruleset
                  response = @client.post("/repos/#{repo_name}/rulesets", required_ruleset_config)
                  $stdout.puts "Successfully created ruleset: #{response[:name]} (ID: #{response[:id]})"

                  @errors.clear
                  @warnings << "Created force push prevention ruleset (ID: #{response[:id]})"
                rescue Octokit::Error => e
                  $stderr.puts "Failed to apply fix: #{e.class} - #{e.message}"
                  $stderr.puts e.backtrace.join("\n") if ENV['DEBUG']
                  @warnings << "Failed to apply fix: #{e.message}"
                rescue StandardError => e
                  $stderr.puts "Unexpected error applying fix: #{e.class} - #{e.message}"
                  $stderr.puts e.backtrace.join("\n") if ENV['DEBUG']
                  @warnings << "Unexpected error applying fix: #{e.message}"
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

                def find_all_branches_ruleset
                  rulesets.find do |ruleset|
                    # Check if this ruleset applies to all branches
                    includes = ruleset.dig(:conditions, :ref_name, :include)
                    includes&.include?('~ALL')
                  end
                end

                def force_push_denied?(existing_ruleset)
                  # Check if ruleset is active
                  return false unless existing_ruleset[:enforcement] == 'active'

                  # Check if there's a non_fast_forward rule
                  existing_ruleset[:rules]&.any? { |rule| rule[:type] == 'non_fast_forward' }
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
