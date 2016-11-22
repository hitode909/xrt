require 'xrt/parser'
require 'xrt/syntax'

module XRT
  class DepthChecker
    def check source
      annotated_source = ''
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

    def max_depth source
      parser = XRT::Parser.new(source)
      syntax = XRT::Syntax.new

      max_level = 0
      current_level = 0

      parser.statements.each{|statement|
        diff = syntax.block_level statement
        current_level += diff
        max_level = [ current_level, max_level].max
      }

      if current_level != 0
        raise 'failed to parse'
      end

      max_level
    end
  end
end
