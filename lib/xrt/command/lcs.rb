require 'xrt/depth_checker'

module XRT
  module Command
    class LCS
      def execute(*files)
        lcs = collect(*files)
        if lcs.length > 0
          report = lcs.map{|statement|
            header = "### Seen #{statement[:count]} times, size: #{statement[:code].length}, mass: #{statement[:mass]}"
            list = statement[:locations].map{|location| "- #{location}" }.join("\n")
            quoted_code = ['```html', statement[:code], '```'].join("\n")
            [header, quoted_code, list].join("\n\n")
          }
          puts report.join("\n\n")
          true
        else
          false
        end
      end

      def collect(*files)
        statements_hash = {}

        files.each{|file|
          next unless File.file? file
          statements(file).each{|statement|
            statements_hash[statement] ||= []
            statements_hash[statement] << file
          }
        }

        statements_hash.each_pair.map{|k, v|
          {
            code: k,
            locations: v.sort,
            count: v.length,
            mass: k.length * v.length,
          }
        }.delete_if{|statement|
          statement[:count] == 1
        }.sort_by{|statement|
          statement[:mass]
        }.reverse
      end

      def statements(file)
        XRT::Parser.new(open(file).read).document.find_blocks.map{|s| s.auto_indent }
      end
    end
  end
end
