module Metrics
  class OrdersWithoutPreferredArtist
    def value
      @value ||= []
    end

    def tally_artist(artist)
      # no-op
    end

    def tally_assignment(assignment)
      artist = assignment.artist
      order = assignment.order
      preferred_artist = order.preferred_artist

      if artist != preferred_artist
        value << order
      end
    end
  end
end
