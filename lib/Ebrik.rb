require 'socket'

require "ebrik/version"
require "ebrik/response"
require "ebrik/request"
require "ebrik/request_parser"
require "ebrik/server"

module Ebrik
  class Error < StandardError; end
  # Your code goes here...

  def self.run
    server = ::Ebrik::Server.new(ENV['HOST'], ENV['PORT'])
    path = ENV['ROOT_PATH'] || Dir.pwd
    app = Rack::Files.new(path)
    server.run(app)
  end
end
