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

                def valid?
                  @errors << "No default (#{@repo.default_branch}) branch protection" unless default_branch_ruleset?

                  @errors.empty? ? :passed : :failed
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
