# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'active_support'
require 'rails/generators/test_case'
require 'way_of_working/audit/github/cis_benchmark'

require 'active_support/testing/autorun'

ActiveSupport.test_order = :random if ActiveSupport.respond_to?(:test_order=)

require 'mocha/minitest'

# Shared fixtures for CIS Benchmark rule tests
module CisBenchmarkTestHelpers
  FakeRepo = Struct.new(:default_branch, :full_name, :private) do
    def private?
      private
    end
  end

  def fake_repo(default_branch: 'main', full_name: 'acme/widgets', private_repo: false)
    FakeRepo.new(default_branch, full_name, private_repo)
  end

  def default_branch_ruleset(name: 'Existing ruleset', enforcement: 'active', rules: [])
    {
      name: name,
      enforcement: enforcement,
      conditions: { ref_name: { include: ['~DEFAULT_BRANCH'], exclude: [] } },
      rules: rules
    }
  end
end
