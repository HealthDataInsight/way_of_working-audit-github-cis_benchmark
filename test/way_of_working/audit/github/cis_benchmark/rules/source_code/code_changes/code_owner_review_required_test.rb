# frozen_string_literal: true

require 'test_helper'

module WayOfWorking
  module Audit
    module Github
      module CisBenchmark
        module Rules
          module SourceCode
            module CodeChanges
              class CodeOwnerReviewRequiredTest < Minitest::Test
                include CisBenchmarkTestHelpers

                def test_passes_when_a_ruleset_requires_code_owner_review
                  ruleset = default_branch_ruleset(rules: [
                                                     { type: 'pull_request', parameters: { require_code_owner_review: true } }
                                                   ])
                  rule = CodeOwnerReviewRequired.new(nil, 'rule', fake_repo, [ruleset], false)

                  rule.validate

                  assert_empty rule.errors
                end

                def test_fails_when_no_ruleset_requires_code_owner_review
                  ruleset = default_branch_ruleset(rules: [{ type: 'pull_request', parameters: {} }])
                  rule = CodeOwnerReviewRequired.new(nil, 'rule', fake_repo, [ruleset], false)

                  rule.validate

                  refute_empty rule.errors
                end

                def test_fix_creates_a_ruleset_when_none_exists
                  client = mock
                  client.expects(:post).with('/repos/acme/widgets/rulesets',
                                             has_entry(name: CodeOwnerReviewRequired::RULESET_NAME))
                  rule = CodeOwnerReviewRequired.new(client, 'rule', fake_repo, [], true)

                  rule.validate

                  assert_empty rule.errors
                end
              end
            end
          end
        end
      end
    end
  end
end
