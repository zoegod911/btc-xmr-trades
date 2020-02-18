class Trader < ApplicationRecord
  extend FriendlyId
  friendly_id :username, use: :scoped, scope: :user

  belongs_to :user
  has_many :offerings, foreign_key: :seller_id
  has_many :buyer_trades, class_name: 'Trade', foreign_key: :buyer_id
  has_many :seller_trades, through: :offerings, source: :trades

  has_many :received_reviews, class_name: 'Review', foreign_key: :reviewee_id
  has_many :left_reviews, class_name: 'Review', foreign_key: :reviewer_id

  has_many :trade_offers, foreign_key: :sender_id
  has_many :trade_requests

  def username
    user.username
  end
  
  def reviews_as_buyer
    self.received_reviews.filter{|r| r.trade.buyer_id == self.id }
  end

  def reviews_as_seller
    self.received_reviews.filter{|r| r.trade.seller.id == self.id }
  end

  def total_completed_trades
    completed_purchases.count + completed_sales.count
  end

  def active_purchases
    buyer_trades.filter(&:active?)
  end

  def disputed_purchases
    buyer_trades.filter(&:disputed?)
  end

  def completed_purchases
    buyer_trades.filter(&:completed?)
  end

  def active_trades
    seller_trades.filter(&:active?)
  end

  def disputed_sales
    seller_trades.filter(&:disputed?)
  end

  def completed_sales
    seller_trades.reject(&:active?)
  end

  def username
    user.username
  end
end
