require_relative 'test_helper'

module Yoink
  class GemServerTest < MiniTest::Unit::TestCase
    include Rack::Test::Methods

    def app
      Yoink::GemServer
    end

    def test_redirect_downloads_to_gems_path
      get '/downloads/rails-3.0.0.gem'

      assert_equal 302, last_response.status
      assert_equal '/gems/rails-3.0.0.gem', URI(last_response.headers['Location']).path
    end

    def test_serves_index_over_s3
      get '/latest_specs.4.8.gz'

      assert_equal 302, last_response.status
      assert_equal 'https://s3.amazonaws.com/production.s3.rubygems.org/latest_specs.4.8.gz', last_response.headers['Location']
    end

    def test_serves_gemspecs_over_mirror
      get '/quick/Marshal.4.8/rails-3.0.0.gemspec.rz'

      assert_equal 302, last_response.status
      assert_equal 'https://bb-m.rubygems.org/quick/Marshal.4.8/rails-3.0.0.gemspec.rz', last_response.headers['Location']
    end

    def test_serves_gems_over_mirror
      get '/gems/rails-3.0.0.gem'

      assert_equal 302, last_response.status
      assert_equal 'https://bb-m.rubygems.org/gems/rails-3.0.0.gem', last_response.headers['Location']
    end
  end
end