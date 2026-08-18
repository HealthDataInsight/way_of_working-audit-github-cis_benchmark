# frozen_string_literal: true

require 'test_helper'

module WayOfWorking
  module Audit
    module Github
      module CisBenchmark
        module Rules
          module SourceCode
            module CodeChanges
              class ResolveConversationsBeforeMergeTest < Minitest::Test
                include CisBenchmarkTestHelpers

                def test_passes_when_a_ruleset_requires_resolved_conversations
                  ruleset = default_branch_ruleset(rules: [
                                                     { type: 'pull_request',
                                                       parameters: { required_review_thread_resolution: true } }
                                                   ])
                  rule = ResolveConversationsBeforeMerge.new(nil, 'rule', fake_repo, [ruleset], false)

                  rule.validate

                  assert_empty rule.errors
                end

                def test_fails_when_no_ruleset_requires_resolved_conversations
                  ruleset = default_branch_ruleset(rules: [{ type: 'pull_request', parameters: {} }])
                  rule = ResolveConversationsBeforeMerge.new(nil, 'rule', fake_repo, [ruleset], false)

                  rule.validate

                  refute_empty rule.errors
                end

                def test_fix_creates_a_ruleset_when_none_exists
                  client = mock
                  client.expects(:post).with('/repos/acme/widgets/rulesets',
                                             has_entry(name: ResolveConversationsBeforeMerge::RULESET_NAME))
                  rule = ResolveConversationsBeforeMerge.new(client, 'rule', fake_repo, [], true)

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
