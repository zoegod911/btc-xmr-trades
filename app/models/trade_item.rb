class TradeItem < ApplicationRecord
  belongs_to :category

  include ImageUploader::Attachment(:thumb)
  include ImageUploader::Attachment(:header)
end
