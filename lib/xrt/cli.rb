require 'xrt/commands'

module XRT
  class CLI
    def execute(args)
      command_name = args.shift

      case command_name
      when 'dump'
        success = XRT::Command::Dump.new.execute(args)
        exit success ? 0 : 1
      when 'dump_blocks'
        XRT::Command::DumpBlocks.new.execute(args)
        exit 0
      when 'extract'
        success = XRT::Command::Extract.new.execute(*args)
        exit success ? 0 : 1
      when 'lcs'
        success = XRT::Command::LCS.new.execute(*args)
        exit success ? 0 : 1
      else
        warn "command not found"
        exit 1
      end
    end

  end
end
