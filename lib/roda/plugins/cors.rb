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
          allow_origin = Cors.cors_header(
            env,
            self.class._cors_allowed_origins
          )

          if env['REQUEST_METHOD'] == 'OPTIONS'
            [200, {
              'Access-Control-Allow-Headers' => 'Authorization,Content-Type',
              'Access-Control-Allow-Origin' => allow_origin
            }, ['']]
          else
            response['Access-Control-Allow-Origin'] = allow_origin
            super
          end
        end
      end


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
    end


    register_plugin(:cors, Cors)
  end
end
