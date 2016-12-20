require 'xrt/syntax'

module XRT
  class Statement
    def initialize(content)
      @content = content
    end

    def content
      @content
    end

    def == other
      self.class == other.class && self.content == other.content
    end

    def inspect
      "(#{self.class}:#{self.content})"
    end

    def children
      []
    end

    def include? statement
      children.each{|child|
        return true if child.equal? statement
        return true if child.include?(statement)
      }
      return false
    end

    def replace_child(new_child, old_child)
      children.each_with_index{|child, index|
        if child.equal? old_child
          children[index] = new_child
          return old_child
        elsif child.replace_child(new_child, old_child)
          return old_child
        end
      }
      nil
    end

    def depth(target)
      children.each{|child|
        return 0 if child.equal? target
        d = child.depth(target)
        if d
          return d + 1
        end
      }
      nil
    end

    def statements
      children.concat(children.map{|child| child.children }.flatten)
    end

    def contains_directive?
      children.any?{|s|
         s.kind_of? XRT::Statement::Directive
      } || children.any?{|c|
        c.contains_directive?
      }
    end

    def find_blocks
      children.select{|child|
        child.kind_of? XRT::Statement::Block
      }.concat(children.map{|child| child.find_blocks }.flatten)
    end

    def find_blocks_with_directive
      children.select{|child|
        child.kind_of?(XRT::Statement::Block) && child.contains_directive?
      }.concat(children.map{|child| child.find_blocks_with_directive }.flatten)
    end

    def find_block_texts
      children.select{|child|
        child.kind_of?(XRT::Statement::Block) || child.kind_of?(XRT::Statement::Text)
      }.concat(children.map{|child| child.find_block_texts }.flatten)
    end

    def auto_indent
      lines = content.split(/\n/)[1..-1]
      whitespaces = lines.map{|line| line.scan(/^\s+/).first }.compact
      indent = whitespaces.sort_by{|whitespace| whitespace.length }.first
      content.gsub(/^#{indent}/, '')
    end
  end

  class Statement
    module Factory
      def self.new_from_content content
        syntax = XRT::Syntax.new

        block_level = syntax.block_level content

        if block_level == 1
          XRT::Statement::Block.new content
        elsif block_level == -1
          XRT::Statement::End.new content
        elsif syntax.block? content
          XRT::Statement::Directive.new content
        elsif syntax.tag_start? content
          XRT::Statement::Tag.new content
        elsif syntax.tag_end? content
          XRT::Statement::TagEnd.new content
        elsif syntax.whitespace? content
          XRT::Statement::Whitespace.new content
        else
          XRT::Statement::Text.new content
        end
      end

    end

    class Document < Statement
      def initialize
        @children = []
      end

      def << statement
        @children << statement
      end

      def children
        @children
      end

      def content
        children.map{|c| c.content }.join
      end

      def == other
        self.content == other.content && self.children.zip(other.children).all{|a, b| p [a, b]; a == b }
      end

      def inspect
        "(#{self.class}:#{self.children})"
      end
    end

    class Text < Statement
    end

    class Whitespace < Statement
    end

    class TagStart < Statement
    end

    class Directive < Statement
    end

    class End < Statement
    end

    class TagEnd < End
    end

    class Block < Statement
      def initialize(content)
        @children = []

        self << Directive.new(content)
      end

      def closed?
        children.last.kind_of? End
      end

      def << statement
        raise "trying to push_child to closed block: #{self.inspect} << #{statement.inspect}" if closed?
        @children << statement
      end

      def children
        @children
      end

      def content
        children.map{|c| c.content }.join
      end

      def inspect
        "(#{self.class}:#{self.children})"
      end
    end

    class Tag < Block
      def initialize content
        @children = []
        tag_start = XRT::Statement::TagStart.new content
        self << tag_start
      end

      def tag_void_element?
        # https://www.w3.org/TR/html5/syntax.html#void-elements
        void_element_names = %w( area base br col embed hr img input keygen link meta param source track wbr )
        void_element_names.include?(self.tag_name)
      end

      def tag_name
        return nil if @children.empty?
        matched = @children[1].content.match(%r{\A/?(\w+)})
        return nil unless matched
        return matched[1].downcase
      end

      def tag_opening?
        !tag_independent? && !tag_closing? && !tag_void_element?
      end

      def tag_closing?
        @children[1].content[0] == '/'
      end

      def tag_independent?
        @children[-2].content[-1] == '/'
      end
    end

    class TagPair < Block
      def initialize tag
        @children = [ tag ]
      end
    end

    class TagPairEnd < End
      def content
        @content.content
      end

      def inspect
      "(#{self.class}:#{@content.inspect})"
      end
    end
  end
end
