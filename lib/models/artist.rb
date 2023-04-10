module Models
  class Artist
    attr_accessor \
      :id,
      :name,
      :capacity,
      :verified,
      :rating,
      :genres

    alias_method :verified?, :verified

    def outrates?(other)
      self.rating > other.rating
    end

    def at_capacity?
      !has_capacity?
    end

    def has_capacity?
      capacity.positive?
    end

    def decrement_capacity
      self.capacity -= 1
    end
  end
end
