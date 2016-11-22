module XRT
  class Statement
    def initialize(content)
      @content = content
    end

    def content
      @content
    end
  end

  class Statement
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
    end
  end
end
