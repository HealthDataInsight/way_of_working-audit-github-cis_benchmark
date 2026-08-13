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
              # This rule checks branch protection is enforced on the default branch
              # and that it meets or exceeds the required configuration.
              class DefaultBranchProtection < ::WayOfWorking::Audit::Github::CisBenchmark::Rules::Base
                include Concerns::RulesetFinder

                RULESET_NAME = 'Way of Working CIS: Default Branch Protection'

                def tags
                  super << :cis_level1
                end

                def validate
                  existing_rulesets = find_default_branch_rulesets

                  if existing_rulesets.empty?
                    @errors << "No default (#{@repo.default_branch}) branch protection"
                    return apply_ruleset_fix if fix

                    return
                  end

                  # Check if any existing ruleset meets requirements
                  return unless existing_rulesets.none? { |ruleset| ruleset_meets_requirements?(ruleset) }

                  @errors << "Default branch protection exists but does not meet requirements " \
                             "(found #{existing_rulesets.size} ruleset(s), none meet requirements)"
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
                  boolean_checks = %i[
                    dismiss_stale_reviews_on_push
                    require_last_push_approval
                    required_review_thread_resolution
                  ]

                  boolean_checks.all? do |key|
                    # If expected is true, actual must be true
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
