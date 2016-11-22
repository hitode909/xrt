base_dir = File.expand_path(File.join(File.dirname(__FILE__), ".."))
lib_dir = File.join(base_dir, "lib")
$LOAD_PATH.unshift(lib_dir)

require 'xrt/parser'

target_file, target_block, replace_to = *ARGV

warn "target_file: #{target_file}"
warn "target_block: #{target_block}"
warn "replace_to: #{replace_to}"

source = open(target_file).read
parser = XRT::Parser.new(source)
doc = parser.document
found = doc.find_blocks.select{|block|
  block.content.index(target_block) == 0
}.first

if found
  puts found.content
else
  warn 'not found'
  exit 1
end

replace_to_node = XRT::Parser.new(replace_to).document

doc.replace_child(replace_to_node, found)

puts doc.content
