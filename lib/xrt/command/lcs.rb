require 'xrt/depth_checker'

module XRT
  module Command
    class LCS
      def execute(*files)
        lcs = collect(*files)
        if lcs.length > 0
          puts lcs.join("\n---\n")
          true
        else
          false
        end
      end

      def collect(*files)
        products = statements(files.shift)
        while files.length > 0
          products = products.product(statements(files.shift))
        end

        products.select{|pairs|
          pairs.flatten.uniq.length == 1
        }.map{|pairs| pairs.first }.sort_by{|s| s.length}
      end

      def statements(file)
        XRT::Parser.new(open(file).read).document.find_blocks.map{|s| s.auto_indent }
      end
    end
  end
end
