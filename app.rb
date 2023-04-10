require "./lib/strategies/status_quo"
require "./lib/simulate"

# TODO: Possibly can fuse `app.rb` and `simulate.rb`. However, this file is
# properly managing input/output to/from core logic, so maybe the separation is
# correct.

strategy_klasses = [Strategies::StatusQuo]
strategy_assignments = Simulate.perform(strategy_klasses)

strategy_assignments.each do |strategy, assignments|
  strategy_name = strategy.name.split("Strategies::").last
  pp "<strategy: #{strategy_name}>"

  assignments.each do |assignment|
    order_id = assignment.order.id
    artist_id = assignment.artist.id

    pp "<order_id: #{order_id}, artist_id: #{artist_id}>"
  end
end
