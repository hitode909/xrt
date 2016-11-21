module XRT
  class Parser
    def initialize(source='')
      @source = source
    end

    def statements
      @source.split(/(\[%[^\]]+%\])/m)
    end
  end
end
