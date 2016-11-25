require 'pathname'
require 'xrt/parser'
require 'xrt/transaction'

module XRT
  module Command

    class Extract
      # xrt extract templates/blogs/index.html '[% IF pager' 'templates/' 'blogs/_pager.tt'
      def execute(from_file, target_block, templates_directory, to_file_name)
        transaction = as_transaction(from_file, target_block, templates_directory, to_file_name)
        transaction.commit!
        true
      end

      def as_transaction(from_file, target_block, templates_directory, to_file_name)
        transaction = XRT::Transaction.new
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
        content_for_new_file = found_block.auto_indent + "\n"

        transaction.edit from_file, content_to_overwrite

        transaction.new_file transaction.full_path(templates_directory, to_file_name), content_for_new_file

        transaction
      end
    end
  end
end
