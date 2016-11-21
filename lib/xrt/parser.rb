module XRT
  class Parser
    def initialize(source='')
      @source = source
    end

    def statements
      reading = @source.clone
      result = []

      while reading.length > 0
        got = read_block(reading) || read_text(reading)
        unless got
          raise "failed to parse #{@source}"
        end
        result << got
      end

      result
    end

    def read_block source
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
