require "./lib/repository"

module Simulate
  class << self
    def perform(strategy, artists, order_queue)
      [].tap do |assignments|
        # The `capacities` collection is really just a calculation derived from
        # our `assignments` collection. But because we have it, we can keep the
        # calculation in sync with a single op rather than iterating everything
        # every time. 
        #
        # Meanwhile, we're taking the philosophy of leaving ground truth
        # immutable so that we don't make a mess and so that our reports
        # downstream are accurate and don't suffer from accidental mutation.
        # Specifically, `artists`, `orders`, and eventually `assignments` are
        # immutable.
        capacities = Capacity.build(artists)
        strategy = strategy.new(artists, capacities)

        order_queue.each do |order|
          artist = strategy.assign(order)
          assignments << Assignment.new(order: order, artist: artist)
          next if artist.nil?

          capacity = capacities[artist.id]
          capacity.decrement

          strategy.update_capacity(
            artist,
            capacity
          )
        end

        assignments.freeze
      end
    end
  end

  class Capacity
    class << self
      def build(artists)
        {}.tap do |memo|
          artists.each do |id, artist|
            memo[id] = new(artist.capacity)
          end
        end
      end
    end

    def initialize(value)
      @value = value
    end

    def exhausted?
      !available?
    end

    def available?
      @value.positive?
    end

    def decrement
      @value -= 1
    end
  end
end
