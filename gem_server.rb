require 'sinatra/base'
require 'yoink/gem_set'

module TorqueBox
  module Middleware
    class Logger
      def initialize(app, logger = nil)
        @app = app
        @logger = logger
      end

      def call(env)
        env['rack.logger'] = logger
        env['rack.errors'] = logger

        @app.call(env)
      end

      private

      def logger
        @logger ||= TorqueBox::Logger.new(@app.class)
      end
    end
  end
end

module Yoink
  class GemServer < Sinatra::Base
    if ENV.has_key?('TORQUEBOX_CONTEXT')
      use TorqueBox::Middleware::Logger, TorqueBox::Logger.new(self)
    end

    configure :production, :development do
      enable :logging, :dump_errors
    end

    def serve_via_s3
      redirect "https://s3.amazonaws.com/production.s3.rubygems.org#{request.path_info}"
    end

    def serve_via_cf
      redirect "https://bb-m.rubygems.org#{request.path_info}"
    end

    get '/specs.4.8.gz' do
      redirect 'https://s3.amazonaws.com/files.yoink.org/specs.4.8.gz'
    end

    get '/' do
      'Dear Comodo,</br><br/>I, Dave Benvenuti, own the site yoink.org and would appreciate if you would approve my SSL certificate signing request so I can begin processing API requests, securely.'
    end

    %w[/specs.4.8.gz
       /latest_specs.4.8.gz
       /prerelease_specs.4.8.gz
    ].each do |index|
      get index do
        content_type('application/x-gzip')
        serve_via_s3
      end
    end

    %w[/quick/rubygems-update-1.3.6.gemspec.rz
       /yaml.Z
       /yaml.z
       /Marshal.4.8.Z
       /quick/index.rz
       /quick/latest_index.rz
    ].each do |deflated_index|
      get deflated_index do
        content_type('application/x-deflate')
        serve_via_s3
      end
    end

    %w[/yaml
       /Marshal.4.8
       /specs.4.8
       /latest_specs.4.8
       /prerelease_specs.4.8
       /quick/index
       /quick/latest_index
    ].each do |old_index|
      head old_index do
        "Please upgrade your RubyGems, it's quite old: http://rubygems.org/pages/download"
      end

      get old_index do
        serve_via_s3
      end
    end

    get "/quick/Marshal.4.8/*.gemspec.rz" do
      content_type('application/x-deflate')
      serve_via_cf
    end

    get "/gems/*.gem" do
      serve_via_cf
    end

    get "/downloads/*.gem" do
      redirect "/gems/#{params[:splat].join}.gem"
    end

    def full_name
      @full_name ||= params[:splat].join.chomp('.gem')
    end
  end
end
