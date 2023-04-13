require "./lib/metrics/genre_capacity"
require "./lib/metrics/orders_without_artist"
require "./lib/metrics/orders_without_preferred_artist"
require "./lib/metrics/orders_without_verified_artist"
require "./lib/metrics/verified_genre_capacity"
require "./lib/simulate"
require "./lib/strategies/alphabetical"
require "./lib/strategies/status_quo"

class App
  STRATEGIES = [
    Strategies::StatusQuo,
    # Ridiculous strategy. Mostly just to demonstrate handling of multiple
    # strategies.
    Strategies::Alphabetical,
  ].freeze

  METRICS = [
    Metrics::GenreCapacity,
    Metrics::VerifiedGenreCapacity,
    Metrics::OrdersWithoutArtist,
    Metrics::OrdersWithoutPreferredArtist,
    Metrics::OrdersWithoutVerifiedArtist,
  ].freeze

  class << self
    # TODO: Present user inputs for `(strategies, metrics)`. Also should take
    # data as an input argument.
    def run(strategies: STRATEGIES, metrics: METRICS)
      new(strategies: strategies, metrics: metrics).run
    end
  end

  def initialize(strategies:, metrics:)
    @strategies = strategies
    @metrics = metrics
  end

  def run
    # TODO: Write somewhere as part of historical reporting system. Fundamental
    # idea is that every output is reproducible whenever it is run because it is
    # fully determined by its inputs.
    report
  end

  private

  def report
    # TODO: Replace with templating engine.
    @report ||=
      String.new.tap do |memo|
        strategy_metrics.each do |strategy, metrics|
          memo << "#{strategy}:"
          memo << "\n"

          metrics.each do |metric|
            memo << "\t"
            memo << "#{metric.class.name}:"
            memo << "\n\t\t"
            memo << "#{format_metric(metric)}"
            memo << "\n\n"
          end

          memo << "\n"
        end
      end
  end

  def strategy_metrics
    @strategy_metrics ||=
      Hash.new { |h, k| h[k] = [] }.tap do |memo|
        # The initial result from tallying static properties of artist is the
        # starting point for every strategies' metrics, so just calculate it
        # one time and later dup it per strategy rather than recalculate.
        initial_metrics = @metrics.map(&:new)
        Repository[:artists].each do |id, artist|
          initial_metrics.each do |metric|
            # Not every metric cares about this data, we could filter those out
            # to save cycles in this artists loop.
            metric.tally_artist(artist)
          end
        end

        @strategies.each do |strategy|
          assignments =
            Simulate.perform(
              strategy,
              Repository[:artists],
              order_queue
            )

          memo[strategy] = dup_metrics(initial_metrics)
          assignments.each do |assignment|
            memo[strategy].each do |metric|
              metric.tally_assignment(assignment)
            end
          end
        end
      end
  end

  def format_metric(metric)
    order_metrics = [
      Metrics::OrdersWithoutArtist,
      Metrics::OrdersWithoutPreferredArtist,
      Metrics::OrdersWithoutVerifiedArtist
    ]

    case metric
    when *order_metrics
      metric.value.map(&:id)
    else
      metric.value
    end
  end

  # Dicey business here. `deep_dup` possibly suffices if we had it, but one
  # can't be too careful.
  def dup_metrics(metrics)
    metrics.map do |metric|
      metric.dup.tap do |metric_dup|
        value = metric_dup.value.dup
        metric_dup.instance_variable_set(
          :@value,
          value
        )
      end
    end
  end

  def order_queue
    # Queue in creation-order which is followed by `id` sequence.
    @order_queue ||=
      Repository[:orders].values
        .sort_by(&:id)
  end
end
