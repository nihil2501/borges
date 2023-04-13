module Strategies
  class StatusQuo
    def initialize(artists, capacities)
      @artists = artists
      @capacities = capacities
    end

    def assign(order)
      artist = order.preferred_artist
      capacity = @capacities[artist.id]

      if capacity.exhausted?
        fallbacks = genre_fallbacks[order.preferred_genre]
        # When there are no more fallbacks, artist is unassigned. This signifies
        # that we got an unassigned order.
        artist = fallbacks.first
      end

      artist
    end

    def update_capacity(artist, capacity)
      return if capacity.available?

      artist.genres.each do |genre|
        fallbacks = genre_fallbacks[genre]
        # `find_index` because we don't have to look any further after 1 found.
        index = fallbacks.find_index { |a| a == artist }
        next if index.nil?

        fallbacks.delete_at(index)
      end
    end

    private

    def genre_fallbacks
      @genre_fallbacks ||=
        Hash.new { |h, k| h[k] = [] }.tap do |memo|
          @artists.each do |id, artist|
            # Are either of these conditions disqualifiers for any viable
            # strategy? For whichever of them is, we can move it up a layer so
            # that it is independent of any particular strategy.
            next unless artist.verified?

            capacity = @capacities[id]
            next if capacity.exhausted?

            artist.genres.each do |genre|
              fallbacks = memo[genre]
              # No tie-breaking logic.
              index = fallbacks.find_index { |a| !a.outrates?(artist) }
              # nil index => insert as only element => `nil.to_i` => 0
              fallbacks.insert(index.to_i, artist)
            end
          end
        end
    end
  end
end
