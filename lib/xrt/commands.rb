require 'pathname'
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

    class Extract
      # xrt extract templates/blogs/index.html '[% IF pager' 'templates/' 'blogs/_pager.tt'
      def execute(from_file, target_block, templates_directory, to_file_name)
        from_source = open(from_file).read
        parser = XRT::Parser.new(from_source)
        from_doc = parser.document

        found_blocks = from_doc.find_blocks.select{|block|
          block.content.index(target_block) == 0
        }

        if found_blocks.length == 0
          raise "target_block not found"
        end

        if found_blocks.length > 1
          raise "ambiguous target_block"
        end

        found_block = found_blocks.first

        replace_to_node = XRT::Parser.new(%Q{[% INCLUDE "#{to_file_name}" %]}).document

        from_doc.replace_child(replace_to_node, found_block)

        content_to_overwrite = from_doc.content
        content_for_new_file = found_block.auto_indent

        open(from_file, 'w'){|f|
          f.write content_to_overwrite
        }

        new_file = Pathname(templates_directory).join(to_file_name)

        if new_file.exist?
          raise 'TO_FILE_NAME exists.'
        end

        open(new_file, 'w'){|f|
          f.puts content_for_new_file
        }

        true
      end
    end
  end
end
