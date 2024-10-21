# frozen_string_literal: true

require 'way_of_working/audit/github'
require 'way_of_working/audit/github/cis_benchmark/rules/all'
require 'zeitwerk'

loader = Zeitwerk::Loader.for_gem_extension(WayOfWorking::Audit::Github)
loader.ignore("#{__dir__}/cis_benchmark/plugin.rb")
loader.setup

module WayOfWorking
  module Audit
    module Github
      module CisBenchmark
        class Error < StandardError; end
      end
    end
  end
end
