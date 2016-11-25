require 'xrt/depth_checker'

module XRT
  module Command
    class LCS
      def execute(*files)
        products = statements(files.shift)
        while files.length > 0
          products = products.product(statements(files.shift))
        end

        puts products.select{|pairs|
          pairs.flatten.uniq.length == 1
        }.map{|pairs| pairs.first }.sort_by{|s| s.length}.join("\n---\n")
      end

      def statements(file)
        XRT::Parser.new(open(file).read).document.find_blocks.map{|s| s.auto_indent }
      end
    end
  end
end
