class Grouping < Hash
  def initialize(klass)
    super() { |h, k| h[k] = klass.new }
  end
end
