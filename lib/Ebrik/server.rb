require 'stringio'
require 'rack'

module Ebrik
  class Server
    def initialize(host, port)
      @app = nil
      @server = TCPServer.new(host, port)
      puts "Starting EBRIK"
      puts "Listening on #{host}:#{port}. Press CTRL+C to cancel."
      @port = port
    end

    def run(app)
      @app = app

      loop do
        Thread.start(@server.accept) do |client|
          handle_connection(client)
        end
      end
    end

    def handle_request(request, client)
      puts "#{client.peeraddr[3]} #{request.path}"

      env = request.meta_vars
      env.delete_if { |k, v| v.nil? }

      rack_input = StringIO.new(request.body.to_s)
      rack_input.set_encoding(Encoding::BINARY)

      env.update(
        Rack::RACK_VERSION      => Rack::VERSION,
        Rack::RACK_INPUT        => rack_input,
        Rack::RACK_ERRORS       => $stderr,
        Rack::RACK_MULTITHREAD  => true,
        Rack::RACK_MULTIPROCESS => false,
        Rack::RACK_RUNONCE      => false,
        Rack::RACK_URL_SCHEME   => "http",
        Rack::RACK_IS_HIJACK    => true,
        Rack::RACK_HIJACK       => lambda { raise NotImplementedError, "only partial hijack is supported."},
        Rack::RACK_HIJACK_IO    => nil,
        Rack::SERVER_PORT       => @port
      )

      env[Rack::QUERY_STRING] ||= ""
      unless env[Rack::PATH_INFO] == ""
        path, n = request.path, (env[Rack::SCRIPT_NAME] || "").length
        env[Rack::PATH_INFO] = path[n, path.length - n]
      end
      env[Rack::REQUEST_PATH] ||= [env[Rack::SCRIPT_NAME], env[Rack::PATH_INFO]].join

      status, headers, body = @app.call(env)

      begin
        response = ::Ebrik::Response.new(status: status, body: body, headers: headers, request: request)
        response.send(client)
      ensure
        body.close  if body.respond_to? :close
      end
    end

    def handle_connection(client)
      request_parser = ::Ebrik::RequestParser.new
      puts "Getting new client #{client}"

      while request_parser.not_finish?
        buf = client.recv(1)
        request_parser.parse(buf)
      end
      request = request_parser.request
      handle_request(request, client)
    end

    def shutdown
      @server.shutdown
    end
  end
end
