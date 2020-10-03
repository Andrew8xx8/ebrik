module Ebrik
  class RequestParser
    attr_reader :request

    def initialize ()
      @request = nil
      @state = :status_line
      @buf = ''
      @line = ''
      @header = ''
      @body = ''
    end

    def not_finish?
      @state != :finished
    end

    def parse_line(buf)
     @line = @line + buf
      if buf == "\n"
        method, path, version = @line.split
        @request = Request.new(method, path, version)
        @state = :header
      end
    end

    def parse_headers(buf)
      @header = @header + buf
      if buf == "\n"
        key, value = @header.gsub(/\r?\n?/, '').split(': ')
        if key.nil? && value.nil?
          if @request.has_body?
            @state = :body
          else
            @state = :finished
          end
        else
         @request.add_header(key, value)
         @header = ""
        end
      end
    end

    def parser_body(buf)
      @body = @body + buf
       if @body.bytesize >= @request.content_length
         @request.add_body(@body)
         @state = :finished
       end
     end


    def parse (buf)
      if @state == :status_line
        parse_line(buf)
      elsif @state == :header
        parse_headers(buf)
      elsif @state == :body
        parser_body(buf)
      end
    end
  end
end
