module XRT
  class Syntax
    def beginning_block? statement
      statement =~ beginning_block_regexp
    end

    def beginning_block_regexp
      keywords = %w(IF UNLESS FOR FOREACH WHILE SWITCH MACRO BLOCK WRAPPER FILTER)
      /\[%.?\s*\b#{keywords.join('|')}\b/
    end

    def end_block_regexp
      /\bEND\b/
    end

    def remove_comment(statement)
      statement.gsub(/\s*#.*$/, '')
    end

    def block_level(statement)
      statement = remove_comment(statement)
      level = 0
      level += 1 if statement =~ beginning_block_regexp
      level -= 1 if statement =~ end_block_regexp
      level
    end
  end
end
