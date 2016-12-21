module XRT
  class Transaction
    attr_reader :files
    def initialize
      @files = {}
    end

    def edit(path, content)
      unless full_path(path).exist?
        raise 'Editing new file'
      end
      if full_path(path).read == content
        return
      end
      add(path, content)
    end

    def new_file(path, content)
      if full_path(path).exist?
        if full_path(path).read == content
          # nothing will change
          return
        else
          raise "File #{path} already exists"
        end
      end

      add(path, content)
    end

    def full_path(*fragments)
      Pathname(fragments.shift).join(*fragments)
    end

    def commit!
      files.each_pair{|path, content|
        unless full_path(path).dirname.exist?
          full_path(path).dirname.mkpath
        end

        full_path(path).open('w') {|f|
          f.write content
        }
      }
    end

    def add(path, content)
      @files[path.to_s] = content
    end
  end
end
