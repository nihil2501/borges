module TestCase
  class << self
    def run(name)
      expected, actual = yield
      result =
        if expected == actual
          "passed"
        else
          puts "expected", expected
          puts "actual", actual

          "^ failed"
        end

      message = "#{result}: #{name}"
      puts message
    end
  end
end
