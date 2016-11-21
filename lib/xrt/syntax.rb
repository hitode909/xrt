module XRT
  class Syntax
    def block? statement
      statement =~ /\A\[%.+%\]\Z/m
    end

    def beginning_block? statement
      without_comment = remove_comment statement
      without_comment =~ beginning_block_regexp
    end

    def end_block? statement
      return unless block? statement
      without_comment = remove_comment statement
      without_comment =~ end_block_regexp
    end

    def beginning_block_regexp
      keywords = %w(IF UNLESS FOR FOREACH WHILE SWITCH MACRO BLOCK WRAPPER FILTER)
      /\[%.?\s*\b(#{keywords.join('|')})\b/i
    end

    def end_block_regexp
      /\bEND\b/i
    end

    def remove_comment(statement)
      statement.gsub(/\s*#.*$/, '')
    end

    def block_level(statement)
      stripped = statement.strip
      return 0 unless block? stripped
      level = 0
      level += 1 if beginning_block? stripped
      level -= 1 if end_block? stripped
      level
    end
  end
end
