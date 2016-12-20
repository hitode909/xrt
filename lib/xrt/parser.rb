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

    # read tokens from tokenized tokens
    # push contents to (container) node
    # returns parsed container node
    # return when tokenized is empty, or node is closed
    def parse_contents(tokenized, node)
      while tokenized.length > 0
        statement = XRT::Statement::Factory.new_from_content(tokenized.shift)

        case statement
        when XRT::Statement::Tag
          parse_contents(tokenized, statement)
          if statement.tag_opening?
            statement = XRT::Statement::TagPair.new(statement)
            parse_contents(tokenized, statement)
            node << statement
            next
          elsif statement.tag_closing?
            statement = XRT::Statement::TagPairEnd.new(statement)
            node << statement
            break
          else
            node << statement
            next
          end
        end

        case statement
        when XRT::Statement::Block
          parse_contents(tokenized, statement)
          node << statement
        when XRT::Statement::End
          node << statement
          break
        else
          node << statement
        end
      end

      node
    end

    def tokens
      reading = @source.dup
      result = []

      while reading.length > 0
        if got = read_directive(reading)
          result << got
        elsif got = read_tag_start(reading)
          result << got
        elsif got = read_tag_end(reading)
          result << got
        elsif got = read_text(reading)
          result.concat(split_whitespace(got))
        else
          raise "failed to parse #{@source}"
        end
      end

      result
    end

    def split_whitespace(text)
      prefix, suffix=nil
      text.sub!(/\A(\s+)/) {|matched|
        prefix = matched
        ''
      }
      text.sub!(/(\s+)\Z/) {|matched|
        suffix = matched
        ''
      }
      [prefix, text, suffix].compact.delete_if{|s| s.empty?}
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
      return nil if source[0] == '<'
      return nil if source[0] == '>'

      buffer = ''
      while true
        return buffer if source[0...2] == '[%'
        return buffer if source[0] == '<'
        return buffer if source[0] == '>'
        break if source.length < 2
        buffer << source.slice!(0)
      end

      buffer << source.slice!(0, source.length)

      buffer
    end

    def read_tag_start source
      return nil unless source[0] == '<'
      source.slice!(0)
    end

    def read_tag_end source
      return nil unless source[0] == '>'
      source.slice!(0)
    end
  end
end
