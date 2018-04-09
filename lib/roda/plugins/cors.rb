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
          response['Access-Control-Allow-Origin'] = Private.cors_header(
            env,
            self.class._cors_allowed_origins
          )
          Private.default_options_handler(env, response, super)
        end
      end


      module Private
        def self.cors_header(env, allowed)
          if (allowed.nil? || allowed.empty?) &&
             %w[development test].include?(ENV['RACK_ENV'])
            '*'
          elsif allowed&.length == 1
            allowed.first
          elsif allowed&.include?(env['HTTP_ORIGIN'])
            env['HTTP_ORIGIN']
          end
        end


        # Reply to OPTIONS request if there's no user-defined route to handle it
        def self.default_options_handler(env, response, response_data)
          if env['REQUEST_METHOD'] == 'OPTIONS' && response_data.first == 404
            response_data[0] = 200
            response['Access-Control-Allow-Headers'] = 'Content-Type'
          end
          response_data
        end
      end
    end

    register_plugin(:cors, Cors)
  end
end
