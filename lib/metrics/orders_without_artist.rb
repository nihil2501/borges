module Metrics
  class OrdersWithoutArtist
    def value
      @value ||= []
    end

    def tally_artist(artist)
      # no-op
    end

    def tally_assignment(assignment)
      if assignment.artist.nil?
        value << assignment.order
      end
    end
  end
end
