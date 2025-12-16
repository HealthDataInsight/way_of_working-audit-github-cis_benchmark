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
              # This rule checks branch protection is enforced on the default branch.
              # Note: This is a pretty weak, because it just requires the presence of
              # a default branch rule, without specifying what it should contain.
              class DefaultBranchProtection < ::WayOfWorking::Audit::Github::CisBenchmark::Rules::Base
                def tags
                  super << :cis_level1
                end

                def validate
                  return if default_branch_ruleset?

                  @errors << "No default (#{@repo.default_branch}) branch protection"

                  return unless fix

                  apply_fix
                end

                def apply_fix
                  repo_name = @repo.full_name
                  $stdout.puts "Applying fix: Creating default branch protection ruleset on #{repo_name}"

                  ruleset_config = {
                    name: 'Way of Working CIS Default Branch Ruleset',
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
                          required_approving_review_count: 1,
                          dismiss_stale_reviews_on_push: true,
                          require_code_owner_review: false,
                          require_last_push_approval: true,
                          required_review_thread_resolution: true,
                          allowed_merge_methods: ['squash']
                        }
                      }
                    ],
                    bypass_actors: []
                  }

                  # Use the GitHub API to create the ruleset
                  response = @client.post("/repos/#{repo_name}/rulesets", ruleset_config)
                  $stdout.puts "Successfully created ruleset: #{response[:name]} (ID: #{response[:id]})"

                  @errors.clear
                  @warnings << "Created Default Branch Protection ruleset (ID: #{response[:id]})"
                rescue Octokit::Error => e
                  $stderr.puts "Failed to apply fix: #{e.class} - #{e.message}"
                  $stderr.puts e.backtrace.join("\n") if ENV['DEBUG']
                  @warnings << "Failed to apply fix: #{e.message}"
                rescue StandardError => e
                  $stderr.puts "Unexpected error applying fix: #{e.class} - #{e.message}"
                  $stderr.puts e.backtrace.join("\n") if ENV['DEBUG']
                  @warnings << "Unexpected error applying fix: #{e.message}"
                end

                def default_branch_ruleset?
                  rulesets.any? do |ruleset|
                    ruleset.dig(:conditions, :ref_name, :include).include?('~DEFAULT_BRANCH')
                  end
                end
              end
            end
          end
        end
      end

      Rules::Registry.register(CisBenchmark::Rules::SourceCode::CodeChanges::DefaultBranchProtection,
                               'Default branch protection')
    end
  end
end
