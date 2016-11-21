require 'xrt/parser'
require 'xrt/syntax'

module XRT
  class DepthChecker
    def check file
      source = open(file).read
      parser = XRT::Parser.new(source)
      syntax = XRT::Syntax.new

      current_level = 0
      parser.statements.each{|statement|
        diff = syntax.block_level statement
        print statement
        if diff != 0
          current_level += diff
          color = diff > 0 ? 31 : 33
          print "\e[#{color}m#{current_level}\e[0m"
        end
      }
      if current_level == 0
        return true
      else
        warn "failed to parse #{file}"
        return false
      end
    end
  end
end
