require "json"

require "./lib/models/artist"
require "./lib/models/order"
require "./lib/utils/grouping"

module Repository
  class << self
    def [](model)
      store[model]
    end

    def reload
      # There are more parsimonious implementations than going back to the raw
      # files to get a new, independent copy of the object graph.
      load_artists
      load_orders
    end

    private

    def load_artists
      kwargs = {
        input_path: "./test/fixtures/small/artists.json",
        input_key: "artists",
        output_key: :artists,
        output_model: Models::Artist,
      }

      load(**kwargs) do |input, output|
        output.id = input["id"]
        output.name = input["name"]
        output.capacity = input["capacity"]
        output.verified = input["verified"]
        output.rating = input["rating"]
        output.genres = input["genre"]
      end
    end

    def load_orders
      kwargs = {
        input_path: "./test/fixtures/small/orders.json",
        input_key: "orders",
        output_key: :orders,
        output_model: Models::Order,
      }

      load(**kwargs) do |input, output|
        output.id = input["id"]
        output.preferred_genre = input["preferred_genre"]
        output.preferred_artist = self[:artists][input["preferred_artist"]]
        output.days_due_from_order = input["days_due_from_order"]
      end
    end

    def load(input_path:, input_key:, output_key:, output_model:)
      inputs = JSON.load_file(input_path)[input_key]
      outputs = self[output_key]

      inputs.each do |input|
        output = output_model.new
        yield(input, output)

        outputs[output.id] = output
      end
    end

    def store
      @store ||= Grouping.new(Hash)
    end
  end
end
