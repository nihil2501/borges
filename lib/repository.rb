require "./lib/models"
require "json"

module Repository
  class << self
    def [](model)
      # Suggests that `unload` could be a useful method that nullifies `@store`.
      reload if @store.nil?
      @store[model]
    end

    private

    # Produces a deeply frozen collection of base data which can therefore be
    # efficiently reused in multiple calculations.
    def reload
      @store = Hash.new { |h, k| h[k] = {} }
      load_artists
      load_orders
      @store.freeze
    end

    def load_artists
      kwargs = {
        input_path: "./test/fixtures/small/artists.json",
        input_key: "artists",
        output_key: :artists,
        output_model: Artist,
      }

      load(**kwargs) do |input|
        {
          id: input["id"],
          name: input["name"],
          capacity: input["capacity"],
          verified: input["verified"],
          rating: input["rating"],
          genres: input["genre"],
        }
      end
    end

    def load_orders
      kwargs = {
        input_path: "./test/fixtures/small/orders.json",
        input_key: "orders",
        output_key: :orders,
        output_model: Order,
      }

      load(**kwargs) do |input|
        {
          id: input["id"],
          preferred_genre: input["preferred_genre"],
          preferred_artist: @store[:artists][input["preferred_artist"]],
          days_due_from_order: input["days_due_from_order"],
        }
      end
    end

    def load(input_path:, input_key:, output_key:, output_model:)
      inputs = JSON.load_file(input_path)[input_key]
      outputs = @store[output_key]

      inputs.each do |input|
        output = output_model.new(**yield(input))
        outputs[output.id] = output
        # Perhaps redundant because the models are already `ReadOnlyStruct`
        output.freeze
      end

      outputs.freeze
    end
  end
end
