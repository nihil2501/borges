module Metrics
  # The counting of capacity isn't totally straightforward due to counting a
  # single artist's capacity across multiple genres.
  class VerifiedGenreCapacity
    def value
      @value ||= Hash.new { |h, k| h[k] = 0 }
    end

    def tally_artist(artist)
      return unless artist.verified?

      artist.genres.each do |genre|
        value[genre] += artist.capacity
      end
    end

    def tally_assignment(assignment)
      artist = assignment.artist
      return if artist.nil?
      return if !artist.verified?

      artist.genres.each do |genre|
        value[genre] -= 1
      end
    end
  end
end
