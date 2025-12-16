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
              # This rule checks branch protection is enforced on the default branch
              # and that it meets or exceeds the required configuration.
              class DefaultBranchProtection < ::WayOfWorking::Audit::Github::CisBenchmark::Rules::Base
                def tags
                  super << :cis_level1
                end

                def validate
                  existing_ruleset = find_default_branch_ruleset

                  unless existing_ruleset
                    @errors << "No default (#{@repo.default_branch}) branch protection"
                    return apply_fix if fix
                    return
                  end

                  # Check if the existing ruleset is as good as our fix
                  unless ruleset_meets_requirements?(existing_ruleset)
                    @errors << "Default branch protection exists but does not meet requirements"
                    return apply_fix if fix
                  end
                end

                def apply_fix
                  repo_name = @repo.full_name
                  $stdout.puts "Applying fix: Creating default branch protection ruleset on #{repo_name}"

                  # Use the GitHub API to create the ruleset
                  response = @client.post("/repos/#{repo_name}/rulesets", required_ruleset_config)
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

                private

                def required_ruleset_config
                  {
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
                end

                def find_default_branch_ruleset
                  rulesets.find do |ruleset|
                    ruleset.dig(:conditions, :ref_name, :include)&.include?('~DEFAULT_BRANCH')
                  end
                end

                def ruleset_meets_requirements?(existing_ruleset)
                  # Check if ruleset is active
                  return false unless existing_ruleset[:enforcement] == 'active'

                  # Find the pull_request rule
                  pr_rule = existing_ruleset[:rules]&.find { |rule| rule[:type] == 'pull_request' }
                  return false unless pr_rule

                  # Get the expected parameters
                  expected_params = required_ruleset_config[:rules].first[:parameters]
                  actual_params = pr_rule[:parameters] || {}

                  # Check each required parameter meets or exceeds expectations
                  check_required_approvals(actual_params, expected_params) &&
                    check_boolean_requirements(actual_params, expected_params) &&
                    check_merge_methods(actual_params, expected_params)
                end

                def check_required_approvals(actual_params, expected_params)
                  # Required approving review count must be at least as high as expected
                  required_count = actual_params[:required_approving_review_count] || 0
                  expected_count = expected_params[:required_approving_review_count]
                  required_count >= expected_count
                end

                def check_boolean_requirements(actual_params, expected_params)
                  # These boolean settings must be enabled if required
                  boolean_checks = [
                    :dismiss_stale_reviews_on_push,
                    :require_last_push_approval,
                    :required_review_thread_resolution
                  ]

                  boolean_checks.all? do |key|
                    # If expected is true, actual must be true
                    # If expected is false, actual can be anything
                    !expected_params[key] || actual_params[key]
                  end
                end

                def check_merge_methods(actual_params, expected_params)
                  # If merge methods are specified, ensure only allowed methods are enabled
                  expected_methods = expected_params[:allowed_merge_methods]
                  actual_methods = actual_params[:allowed_merge_methods]

                  # If no restriction is set in the actual ruleset, it's less strict
                  return false if actual_methods.nil? || actual_methods.empty?

                  # Check that actual methods are a subset of or equal to expected methods
                  actual_methods.all? { |method| expected_methods.include?(method) }
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
