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
      "<#{self.class}:#{self.content}>"
    end

    def children
      []
    end

    def replace_child(new_child, old_child)
      children.each_with_index{|child, index|
        if child.equal? old_child
          children[index] = new_child
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
        "<#{self.class}:#{self.children}>"
      end
    end

    class Text < Statement
    end

    class Directive < Statement
    end

    class End < Directive
    end

    class Block < Directive
      def initialize(content)
        super
        @children = []
      end

      def closed?
        children.last.kind_of? End
      end

      def << statement
        raise 'trying to push_child to closed block' if closed?
        @children << statement
      end

      def children
        @children
      end

      def content
        @content + children.map{|c| c.content }.join
      end

      def inspect
        "<#{self.class}:#{@content},#{self.children}>"
      end
    end
  end
end
