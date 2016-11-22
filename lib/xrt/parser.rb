require 'xrt/statement'

module XRT
  class Parser
    def initialize(source='')
      @source = source
    end

    def document
      doc = XRT::Statement::Document.new

      tokenized = self.tokens

      parse_contents(tokenized, doc)
      doc
    end

    def parse_contents(tokenized, node)
      while tokenized.length > 0
        statement = XRT::Statement::Factory.new_from_content(tokenized.shift)
        case statement
        when XRT::Statement::Block
          parse_contents(tokenized, statement)
          node << statement
        when XRT::Statement::End
          node << statement
          break
        when XRT::Statement::Text
          node << statement
        when XRT::Statement::Directive
          node << statement
        end
      end

      node
    end

    def tokens
      reading = @source.dup
      result = []

      while reading.length > 0
        got = read_directive(reading) || read_text(reading)
        unless got
          raise "failed to parse #{@source}"
        end
        result << got
      end

      result
    end

    def read_directive source
      return nil unless source[0...2] == '[%'

      buffer = ''
      while source[0...2] != '%]'
        buffer << source.slice!(0)
      end
      buffer << source.slice!(0, 2)
      buffer
    end

    def read_text source
      return nil if source[0...2] == '[%'

      buffer = ''
      while true
        return buffer if source[0...2] == '[%'
        break if source.length < 2
        buffer << source.slice!(0)
      end

      buffer << source.slice!(0, source.length)

      buffer
    end
  end
end
