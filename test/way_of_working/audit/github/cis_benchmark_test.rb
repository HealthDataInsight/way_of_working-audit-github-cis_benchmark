# frozen_string_literal: true

require 'test_helper'

module WayOfWorking
  module Audit
    module Github
      class CisBenchmarkTest < Minitest::Test
        def test_that_it_has_a_version_number
          refute_nil CisBenchmark::VERSION
        end
      end
    end
  end
end
