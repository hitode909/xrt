module XRT
  class Transaction
    attr_reader :directory
    attr_reader :files
    def initialize(directory)
      @directory = directory
      @files = {}
    end

    def add(path, content)
      @files[path] = content
    end

    def full_path(*fragments)
      Pathname(directory).join(*fragments)
    end

    def commit!
      files.each_pair{|path, content|
        full_path(path).open('w') {|f|
          f.write content
        }
      }
    end
  end
end
