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
              # This rule checks a CODEOWNERS file is present, so owners can be set for
              # extra sensitive code or configuration.
              class CodeOwnersFilePresent < ::WayOfWorking::Audit::Github::CisBenchmark::Rules::Base
                # GitHub recognises a CODEOWNERS file in any of these locations.
                CODEOWNERS_PATHS = ['CODEOWNERS', '.github/CODEOWNERS', 'docs/CODEOWNERS'].freeze

                def tags
                  super << :cis_level1
                end

                def validate
                  return if CODEOWNERS_PATHS.any? { |path| codeowners_file_exists?(path) }

                  @errors << 'No CODEOWNERS file found (checked CODEOWNERS, .github/CODEOWNERS, docs/CODEOWNERS)'
                end

                private

                def codeowners_file_exists?(path)
                  @client.contents(@repo_name, path: path)
                  true
                rescue Octokit::NotFound
                  false
                end
              end
            end
          end
        end
      end

      Rules::Registry.register(CisBenchmark::Rules::SourceCode::CodeChanges::CodeOwnersFilePresent,
                               'CODEOWNERS file present')
    end
  end
end
