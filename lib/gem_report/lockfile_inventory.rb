module GemReport
  class LockfileInventory
    def initialize(lockfile_path)
      @path = lockfile_path
    end

    def analyze
      data = File.read(@path)
      Bundler::LockfileParser.new(data)
    end
  end
end