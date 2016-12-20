require 'xrt/depth_checker'

module XRT
  module Command
    class DumpBlocks
      def execute(files)
        files.each{|file|
          puts dump_file file
        }
      end

      def dump_file file
        blocks = find_blocks file
        puts blocks.join("\n=====\n")
      end

      def find_blocks(file)
        XRT::Parser.new(open(file).read).document.find_blocks_with_directive.map{|s| s.auto_indent }
      end
    end
  end
end
