# frozen_string_literal: true

require 'pathname'

module WayOfWorking
  module Audit
    module Github
      # Mixin that provides a couple of pathname convenience methods
      module CisBenchmark
        class << self
          def root
            Pathname.new(File.expand_path('../../../..', __dir__))
          end

          def source_root
            root.join('lib', 'way_of_working', 'audit', 'github', 'cis_benchmark', 'templates')
          end
        end
      end
    end
  end
end
