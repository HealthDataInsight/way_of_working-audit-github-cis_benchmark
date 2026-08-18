# frozen_string_literal: true

require 'test_helper'

module WayOfWorking
  module Audit
    module Github
      module CisBenchmark
        module Rules
          module SourceCode
            module CodeChanges
              class CodeOwnersFilePresentTest < Minitest::Test
                include CisBenchmarkTestHelpers

                def test_passes_when_codeowners_file_exists_at_root
                  client = mock
                  client.expects(:contents).with('acme/widgets', path: 'CODEOWNERS').returns(true)
                  rule = CodeOwnersFilePresent.new(client, 'rule', fake_repo, [], false)

                  rule.validate

                  assert_empty rule.errors
                end

                def test_fails_when_no_codeowners_file_is_found_in_any_location
                  client = mock
                  client.stubs(:contents).raises(Octokit::NotFound)
                  rule = CodeOwnersFilePresent.new(client, 'rule', fake_repo, [], false)

                  rule.validate

                  refute_empty rule.errors
                end
              end
            end
          end
        end
      end
    end
  end
end
