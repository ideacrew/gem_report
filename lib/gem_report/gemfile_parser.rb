module GemReport
  class GemfileParser
    def self.parse(gemfile_path)
      dsl = Bundler::Dsl.new()
      dsl.eval_gemfile(gemfile_path)
      dsl
    end
  end
end