# frozen_string_literal: true

require 'way_of_working/audit/github/rules/base'

module WayOfWorking
  module Audit
    module Github
      # This is the namespace for GitHub rules
      module CisBenchmark
        module Rules
          # This rule checks branch protection is enforced on the default branch.
          class Base < ::WayOfWorking::Audit::Github::Rules::Base
            # We are deliberately overiding the default way_of_working tag
            # for CIS Benchmark rules.
            def tags
              [:cis]
            end
          end
        end
      end
    end
  end
end
