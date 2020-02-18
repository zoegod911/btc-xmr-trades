require 'rqrcode'


class Trade < ApplicationRecord
  include ImageUploader::Attachment(:qr_code)

  enum status: %i(in_progress user_paid completed expired disputed)

  belongs_to :offering
  belongs_to :buyer, class_name: 'Trader', foreign_key: :buyer_id

  has_one :trade_dispute, dependent: :destroy
  has_one :trade_escrow, dependent: :destroy
  has_one :trade_chat, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_one :seller, through: :offering, foreign_key: :seller_id


  def time_until_expiry(raw: false)
    time_diff = Time.now - self.expires_at

    diff = Time.at(time_diff.to_i.abs).utc

    raw ? diff : diff.strftime('%H:%M:%S')
  end

  def active?
    %w(in_progress user_paid).include? self.status
  end

  def complete?
    self.status == 'completed'
  end

  def disputed?
    self.status == 'disputed'
  end

  def expired?
    self.status == 'expired'
  end

  def coin_amount
    self.trade_escrow.coin_amount
  end

  def coin_type
    self.offering.coin_type
  end

  def create_qr_code
    if self.qr_code_data.nil? && self.trade_escrow.coin_address.present?
      coin_type     = self.offering.coin_type
      coin_amount   = self.trade_escrow.coin_amount
      coin_address  = self.trade_escrow.coin_address

      url = "bitcoin:#{coin_address}?amount=#{coin_amount}"

      qrcode = RQRCode::QRCode.new(url)

      png = qrcode.as_png(
        file: nil,
        size: 300,
        bit_depth: 1,
        fill: 'white',
        color: 'black',
        coding: 'utf8',
        border_modules: 4,
        module_px_size: 6,
        resize_gte_to: false,
        resize_exactly_to: false,
        color_mode: ChunkyPNG::COLOR_GRAYSCALE,
      )

      IO.write('/tmp/qrcode.png', png.to_s.force_encoding('UTF-8'))
      self.qr_code = File.open('/tmp/qrcode.png')

      self.save!
    end
  end
end
