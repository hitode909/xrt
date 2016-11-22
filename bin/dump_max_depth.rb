base_dir = File.expand_path(File.join(File.dirname(__FILE__), ".."))
lib_dir = File.join(base_dir, "lib")
$LOAD_PATH.unshift(lib_dir)

require 'xrt/depth_checker'

target_files = ARGV

checker = XRT::DepthChecker.new

target_files.each{|target_file|
  level = checker.max_depth open(target_file).read
  puts [level, target_file].join("\t")
}

exit 0
