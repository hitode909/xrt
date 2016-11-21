base_dir = File.expand_path(File.join(File.dirname(__FILE__), ".."))
lib_dir = File.join(base_dir, "lib")
$LOAD_PATH.unshift(lib_dir)

require 'xrt/depth_checker'

target_files = ARGV

checker = XRT::DepthChecker.new

target_files.each_with_index{|target_file, index|
  warn "Checking #{target_file}"
  parsed, annotated_source = checker.check target_file
  unless parsed
    warn annotated_source
    warn "Failed to parser #{target_file} (#{index}/#{target_files.length})"
    exit 1
  end
}

exit 0
