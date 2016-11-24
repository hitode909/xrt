require 'xrt/depth_checker'

module XRT
  module Command
    class Dump
      def execute(files)
        files.each{|file|
          dump_file file
        }
      end

      def dump_file target_file
        warn "Dumping #{target_file}"
        checker = XRT::DepthChecker.new
        parsed, annotated_source = checker.check open(target_file).read
        puts annotated_source
        unless parsed
          raise "Failed to parser #{target_file} (#{index}/#{target_files.length})"
        end
      end
    end
  end
end
