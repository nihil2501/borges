class ReadOnlyStruct < Struct
  class << self
    def new(...)
      # Not totally sure this is correct, but I'm witnessing at least some
      # satisfactory level of working.
      super.tap do |klass|
        klass.members.each do |member|
          klass.undef_method :"#{member}="
        end
      end
    end
  end
end

artist_members = [
  :id,
  :name,
  :capacity,
  :verified,
  :rating,
  :genres,
]

Artist =
  ReadOnlyStruct.new(*artist_members, keyword_init: true) do
    alias_method :verified?, :verified

    def outrates?(other)
      self.rating > other.rating
    end
  end

Assignment =
  ReadOnlyStruct.new(
    :order,
    :artist,
    keyword_init: true
  )

module Genres
  ALL = [
    COUNTRY = "country".freeze,
    R_AND_B = "r&b".freeze,
    SINGER_SONGWRITER = "singer-songwriter".freeze,
  ].freeze
end

Order =
  ReadOnlyStruct.new(
    :id,
    :preferred_artist,
    :preferred_genre,
    :days_due_from_order,
    keyword_init: true
  )
