class Category < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  has_ancestry cache_depth: true
  
  has_many :trade_items
end
