require 'ebrik'

module Rack
  module Handler
    class Ebrik
      def self.run(app, **options)
        environment  = ENV['RACK_ENV'] || 'development'
        default_host = environment == 'development' ? 'localhost' : nil

        if !options[:BindAddress] || options[:Host]
          options[:BindAddress] = options.delete(:Host) || default_host
        end
        options[:Port] ||= 8080

        @server = ::Ebrik::Server.new(options[:Host], options[:Port])
        @server.run(app)
      end

      def self.valid_options
        environment  = ENV['RACK_ENV'] || 'development'
        default_host = environment == 'development' ? 'localhost' : '0.0.0.0'

        {
          "Host=HOST" => "Hostname to listen on (default: #{default_host})",
          "Port=PORT" => "Port to listen on (default: 8080)",
        }
      end

      def self.shutdown
        if @server
          @server.shutdown
          @server = nil
        end
      end

    end

    register 'ebrik', 'Rack::Handler::Ebrik'
  end
end
