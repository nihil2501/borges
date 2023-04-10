require "./lib/utils/grouping"
require "./lib/models/assignment"

module Strategies
  class StatusQuo
    def initialize(artists)
      @artists = artists
    end

    def perform(order)
      Models::Assignment.new.tap do |assignment|
        assignment.order = order
        assignment.artist = order.preferred_artist

        if assignment.artist.at_capacity?
          fallbacks = genre_fallbacks[order.preferred_genre]
          assignment.artist = fallbacks.first
        end
      end
    end

    def update_artists(artist)
      return if artist.has_capacity?

      artist.genres.each do |genre|
        fallbacks = genre_fallbacks[genre]
        index = fallbacks.find_index { |a| a == artist }
        next if index.nil?

        fallbacks.delete_at(index)
      end
    end

    private

    def genre_fallbacks
      @genre_fallbacks ||=
        Grouping.new(Array).tap do |memo|
          @artists.each do |id, artist|
            # Are either of these conditions disqualifiers for any viable
            # strategy? For whichever is, we can move it up a layer so that it
            # is independent of any particular strategy.
            next unless artist.verified?
            next if artist.at_capacity?

            artist.genres.each do |genre|
              fallbacks = memo[genre]
              index = fallbacks.find_index { |a| !a.outrates?(artist) }
              # nil index => insert as only element => `nil.to_i`
              fallbacks.insert(index.to_i, artist)
            end
          end
        end
    end
  end
end
