require 'xrt/parser'
require 'xrt/syntax'

module XRT
  class DepthChecker
    def check file
      annotated_source = ''
      source = open(file).read
      parser = XRT::Parser.new(source)
      syntax = XRT::Syntax.new

      current_level = 0
      parser.statements.each{|statement|
        diff = syntax.block_level statement
        annotated_source += statement
        if diff != 0
          current_level += diff
          color = diff > 0 ? 31 : 33
          annotated_source += "\e[#{color}m#{current_level}\e[0m"
        end
      }
      if current_level == 0
        return true, annotated_source
      else
        return false, annotated_source
      end
    end
  end
end
