require "./lib/simulate"
require "./lib/strategies/status_quo"
require "./test/utils"

TestCase.run("status quo assignments") do
  order_queue = Repository[:orders].values.sort_by(&:id)

  assignments =
    Simulate.perform(
      Strategies::StatusQuo,
      Repository[:artists],
      order_queue
    )

  actual =
    assignments.map do |assignment|
      {
        order_id: assignment.order.id,
        artist_id: assignment.artist.id,
      }
    end

  expected = [
    { order_id: 1,  artist_id: 1 },
    { order_id: 2,  artist_id: 2 },
    { order_id: 3,  artist_id: 1 },
    { order_id: 4,  artist_id: 3 },
    { order_id: 5,  artist_id: 3 },
    { order_id: 6,  artist_id: 5 },
    { order_id: 7,  artist_id: 4 },
    { order_id: 8,  artist_id: 5 },
    { order_id: 9,  artist_id: 1 },
    { order_id: 10, artist_id: 4 },
  ]

  [expected, actual]
end
