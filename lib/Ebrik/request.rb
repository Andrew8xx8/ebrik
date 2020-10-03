require 'uri'

module Ebrik
  class Request
    attr_reader :method, :path, :version, :headers, :body

    def initialize(method, path, version)
      @method = method
      @path = path
      @version = version
      @headers = {}
      @body = ""
    end

    def add_header (key, value)
      @headers[key.downcase] = value
    end

    def has_body?
      @headers.key?("Content-Length")
    end

    def content_length
      @headers["Content-Length"].to_i
    end

    def add_body(body)
      @body = body
    end

    def uri
      URI::parse(path.sub(%r{\A/+}o, '/'))
    end

    def meta_vars
      meta = Hash.new

      content_length = @headers["Content-Length"]
      content_type = @headers["Content-Type"]

      meta["CONTENT_LENGTH"]    = content_length if content_length.to_i > 0
      meta["CONTENT_TYPE"]      = content_type.dup if content_type
      meta["GATEWAY_INTERFACE"] = "CGI/1.1"
      meta["REQUEST_METHOD"]    = @method.dup
      meta["REQUEST_URI"]       = @uri.to_s
      meta["SCRIPT_NAME"]       = @uri.to_s
      meta["SERVER_NAME"]       = @headers["host"]

      @headers.each{|key, val|
        next if /^content-type$/i =~ key
        next if /^content-length$/i =~ key
        name = "HTTP_" + key
        name.gsub!(/-/o, "_")
        name.upcase!
        meta[name] = val
      }

      meta
    end
  end
end
