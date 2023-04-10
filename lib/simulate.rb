require "./lib/repository"
require "./lib/simulate"
require "./lib/utils/grouping"

module Simulate
  class << self
    def perform(strategy_klasses)
      Grouping.new(Array).tap do |strategy_assignments|
        strategy_klasses.each do |klass|
          # Get a new, independent copy of the object graph because we do some
          # mutation of state possibly demanded by strategy.
          Repository.reload

          # Queued in order of creation which follows `id` sequence. 
          order_queue = Repository[:orders].values.sort_by(&:id)
          strategy = klass.new(Repository[:artists])
          assignments = strategy_assignments[klass]

          order_queue.each do |order|
            assignment = strategy.perform(order)
            assignments << assignment

            artist = assignment.artist
            next if artist.nil?

            artist.decrement_capacity
            strategy.update_artists(artist)
          end
        end
      end
    end
  end
end
