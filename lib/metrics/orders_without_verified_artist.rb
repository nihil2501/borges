module Metrics
  class OrdersWithoutVerifiedArtist
    def value
      @value ||= []
    end

    def tally_artist(artist)
      # no-op
    end

    def tally_assignment(assignment)
      return if assignment.artist&.verified?
      value << assignment.order
    end
  end
end
