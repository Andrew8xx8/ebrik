require 'stringio'

module Ebrik
  class Response
    attr_reader :status

    def initialize(status:, headers: {}, body: [], request:)
      @status = status
      @body = body
      @headers = headers
      @request = request
    end

    def setup_headers
      if @status == 304 || @status == 204
        @headers.delete('Content-Length')
        @body = ""
      elsif @headers['Content-Length'].nil?
        @headers['Content-Length'] = (@body && @body.respond_to?(:join) ? @body.join.bytesize : 0).to_s
      end
    end

    def send_headers(client)
      rest_headers = ""

      @headers.each { |key, val|
        rest_headers += "#{key}: #{val}\r\n"
      }

      headers = "HTTP/1.1 #{@status}\r\n" +
      rest_headers +
      "\r\n"

      client.write(headers)
    end

    def send_body(client)
      return if @request.method == "HEAD"

      @body.each { |part|
        client.write(part)
      }
    end

    def send(client)
      setup_headers
      send_headers(client)
      send_body(client)
    end
  end
end
