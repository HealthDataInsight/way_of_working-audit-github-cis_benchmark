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
              # This rule checks that previous approvals are dismissed when updates are introduced to
              # a code change proposal.
              class PreviousPrApprovalsDismissed < ::WayOfWorking::Audit::Github::CisBenchmark::Rules::Base
                def tags
                  super << :cis_level1
                end

                def validate
                  @errors << 'Ensure previous PR approvals are dismissed' unless previous_approvals_dismissed?
                end

                def previous_approvals_dismissed?
                  rulesets.any? do |ruleset|
                    includes = ruleset.dig(:conditions, :ref_name, :include)
                    next false unless includes&.include?('~DEFAULT_BRANCH')

                    ruleset[:rules]&.any? do |rule|
                      next false unless rule[:type] == 'pull_request'

                      rule.dig(:parameters, :dismiss_stale_reviews_on_push)
                    end
                  end
                end
              end
            end
          end
        end
      end

      Rules::Registry.register(CisBenchmark::Rules::SourceCode::CodeChanges::PreviousPrApprovalsDismissed,
                               '1.1.4 Previous PR approvals dismissed')
    end
  end
end
