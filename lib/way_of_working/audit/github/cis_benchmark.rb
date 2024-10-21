# frozen_string_literal: true

require 'way_of_working'
require_relative 'cis_benchmark/paths'
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

  module SubCommands
    # # This reopens the "way_of_working exec" sub command
    # class Exec
    #   register(Audit::Github::CisBenchmark::Generators::Exec, 'audit', 'audit',
    # end

    # # This reopens the "way_of_working init" sub command
    # class Init
    #   register(Audit::Github::CisBenchmark::Generators::Init, 'audit', 'audit',
    # end

    # # This reopens the "way_of_working new" sub command
    # class New
    #   register(Audit::Github::CisBenchmark::Generators::New, 'audit', 'audit',
    # end
  end
end
