# frozen_string_literal: true

require 'roda'

require_relative 'cors/version'


class Roda
  module RodaPlugins
    module Cors
      def self.configure(app, allowed_origins: nil)
        app._cors_allowed_origins = allowed_origins
      end


      module ClassMethods
        attr_accessor :_cors_allowed_origins
      end


      module InstanceMethods
        def call(&block)
          allowed = self.class._cors_allowed_origins
          response['Access-Control-Allow-Origin'] =
            if (allowed.nil? || allowed.empty?) &&
               %w[development test].include?(ENV['RACK_ENV']) ||
               allowed&.first == '*'
              '*'
            elsif allowed&.include?(env['HTTP_ORIGIN'])
              env['HTTP_ORIGIN']
            end

          default_options_handler(super)
        end


        # Reply to OPTIONS request if there's no user-defined route to handle it
        def default_options_handler(response_data)
          if env['REQUEST_METHOD'] == 'OPTIONS'
            response['Access-Control-Allow-Headers'] = 'Content-Type'
            response_data[0] = 200 if response_data.first == 404
          end
          response_data
        end
      end
    end


    register_plugin(:cors, Cors)
  end
end
