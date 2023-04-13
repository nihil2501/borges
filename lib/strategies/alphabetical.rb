module Strategies
  class Alphabetical
    def initialize(artists, capacities)
      @artists = artists
      @capacities = capacities
    end

    def assign(order)
      artist_queue.first
    end

    def update_capacity(artist, capacity)
      if capacity.exhausted?
        artist_queue.delete(artist)
      end
    end

    private

    def artist_queue
      @artist_queue ||=
        @artists.each_value
          .select(&method(:available?))
          .sort_by(&:name)
    end

    def available?(artist)
      capacity = @capacities[artist.id]
      capacity.available?
    end
  end
end
