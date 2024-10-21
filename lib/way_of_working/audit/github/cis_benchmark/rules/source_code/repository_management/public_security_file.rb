# frozen_string_literal: true

require 'way_of_working/audit/github/cis_benchmark/rules/base'

module WayOfWorking
  module Audit
    # This is the namespace for the GitHub audit
    module Github
      module CisBenchmark
        module Rules
          module SourceCode
            module RepositoryManagement
              # This rule checks all public repositories contain a SECURITY.md file.
              class PublicSecurityFile < ::WayOfWorking::Audit::Github::CisBenchmark::Rules::Base
                def tags
                  super << :cis_level1
                end

                def valid?
                  return :not_applicable if @repo.private?

                  begin
                    @client.contents(@repo_name, path: 'SECURITY.md')
                  rescue Octokit::NotFound
                    @errors << 'All public repositories must contain a SECURITY.md file.'
                  end

                  @errors.empty? ? :passed : :failed
                end
              end
            end
          end
        end
      end

      Rules::Registry.register(CisBenchmark::Rules::SourceCode::RepositoryManagement::PublicSecurityFile,
                               'Public SECURITY.md File')
    end
  end
end
