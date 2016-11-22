base_dir = File.expand_path(File.join(File.dirname(__FILE__), ".."))
lib_dir = File.join(base_dir, "lib")
$LOAD_PATH.unshift(lib_dir)

require 'xrt/parser'
require 'pp'

target_files = ARGV

target_files.each_with_index{|target_file, index|
  warn "Dumping #{target_file}"
  source = open(target_file).read
  parser = XRT::Parser.new(source)
  pp parser.document
}

exit 0
