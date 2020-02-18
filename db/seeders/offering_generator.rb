require "#{Rails.root}/db/seeders/trader_generator"


class OfferingGenerator
  COIN_TYPES = %w(BTC XMR)

  def self.generate!
    new.generate!
  end

  def generate!
    trade_items = TradeItem.all
    traders = (1..50).to_a.map do |vendor_num|
      puts "Creating Dummy User for Trader: ##{vendor_num} of 50"
      TraderGenerator.generate!
    end

    minimum_successful_trades = (0..15).to_a
    minimum_prices = [10, 20, 50, 100, 200, 300, 400, 500, 800, 1000, 2000]
    max_prices = [200, 500, 600, 700, 800, 900, 1000, 1500, 2000, 3000, 4000]


    coin_prices = {}
    COIN_TYPES.each do |coin|
      value = CryptoConversion.convert(
        from_currency: coin,
        to_currency: 'USD',
        coin_amount: 1
      )

      coin_prices[coin] = value
    end

    500.times {
      trader = traders.sample

      (5..10).to_a.sample.times {
        coin_type       = COIN_TYPES.sample
        current_price   = coin_prices[coin_type]

        multiplier_price = current_price
        multiplier_price = multiplier_price / 1000000000000 if coin_type == 'XMR'

        ppc_multiplier = multiplier_price > 100 ? 4 : 2
        ppc_lowend = multiplier_price > 2100 ? 3 : 2
        decimal     = Faker::Number.decimal(
          l_digits: (ppc_lowend..ppc_multiplier).to_a.sample,
          r_digits: (1..2).to_a.sample
        )

        trade_item      = trade_items.sample
        price_per_coin  = current_price.to_f + decimal

        max_price = max_prices.sample
        min_price = minimum_prices.select do |min_price|
          max_price > min_price
        end.sample

        Offering.create(
          seller_id: trader.id,
          coin_type: coin_type,
          minimum_price: min_price,
          maximum_price: max_price,
          price_per_coin: price_per_coin,
          trade_item_id: trade_item.id,
          description: Faker::Lorem.paragraph,
          target_currency: trader.user.default_currency,
          minimum_trades_completed: minimum_successful_trades.sample
        )
      }
    }
  end
end
