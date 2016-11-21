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
        current_level += diff
        annotated_source += statement

        color = 44 + diff
        if STDOUT.tty?
          annotated_source += "\e[#{color}m#{current_level}\e[0m"
        else
          annotated_source += current_level.to_s
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
