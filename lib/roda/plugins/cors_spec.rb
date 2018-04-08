# frozen_string_literal: true

require 'spec_helper'


describe Roda::RodaPlugins::Cors do
  it 'has a version number' do
    ::Roda::RodaPlugins::Cors::VERSION.wont_be_nil
  end

  describe 'with default options' do
    let(:app) do
      dummy_app do
        plugin :cors
      end
    end
  end

  describe 'with empty allowed_origins' do
    let(:app) do
      dummy_app do
        plugin :cors, allowed_origins: []
      end
    end
  end

  describe 'with a single allowed_origin' do
    let(:app) do
      dummy_app do
        plugin :cors, allowed_origins: ['http://hips.com']
      end
    end
  end

  describe 'with multiple allowed_origins' do
    let(:app) do
      dummy_app do
        plugin :cors, allowed_origins: ['http://hips.com', 'http://dontlie.com']
      end
    end
  end
end
