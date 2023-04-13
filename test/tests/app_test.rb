require "./app"
require "./test/utils"

TestCase.run("report for 2 strategies and 5 metrics") do
  expected =
    <<~HEREDOC
      Strategies::StatusQuo:
      	Metrics::GenreCapacity:
      		{"singer-songwriter"=>1, "country"=>0, "r&b"=>0}

      	Metrics::VerifiedGenreCapacity:
      		{"singer-songwriter"=>1, "country"=>0, "r&b"=>0}

      	Metrics::OrdersWithoutArtist:
      		[]

      	Metrics::OrdersWithoutPreferredArtist:
      		[9, 10]

      	Metrics::OrdersWithoutVerifiedArtist:
      		[4, 5]


      Strategies::Alphabetical:
      	Metrics::GenreCapacity:
      		{"singer-songwriter"=>0, "country"=>0, "r&b"=>1}

      	Metrics::VerifiedGenreCapacity:
      		{"singer-songwriter"=>0, "country"=>0, "r&b"=>1}

      	Metrics::OrdersWithoutArtist:
      		[]

      	Metrics::OrdersWithoutPreferredArtist:
      		[2, 4, 5, 6, 7, 8, 9]

      	Metrics::OrdersWithoutVerifiedArtist:
      		[6, 7]
    HEREDOC

  actual = App.run.tap(&:strip!)
  expected.chomp!

  [expected, actual]
end
