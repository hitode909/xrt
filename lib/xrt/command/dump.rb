require 'xrt/depth_checker'

module XRT
  module Command
    class Dump
      def execute(files)
        files.each{|file|
          puts annotate_file file, STDOUT.tty?
        }
      end

      def annotate_file target_file, enable_color=nil
        checker = XRT::DepthChecker.new
        parsed, annotated_source = checker.check open(target_file).read, enable_color
        unless parsed
          raise "Failed to parse #{target_file}"
        end
        annotated_source
      end
    end
  end
end
