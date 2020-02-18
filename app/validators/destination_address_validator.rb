class DestinationAddressValidator < ActiveModel::Validator
  def validate(record)
    seller_address = record.destination.try(:[], 'seller')
    buyer_address = record.destination.try(:[], 'buyer')

    if seller_address
      seller_address_valid = WalletService.validate_address(
        coin_type: record.trade.coin_type,
        address: seller_address
      )

      unless seller_address_valid
        msg = "Seller's destination #{record.trade.coin_type} address is invalid..."
        record.errors.add(:destination, msg)
      end
    end

    if buyer_address
      buyer_address_valid = WalletService.validate_address(
        coin_type: record.trade.coin_type,
        address: buyer_address
      )

      unless buyer_address_valid
        msg = "Buyer's destination #{record.trade.coin_type} address is invalid..."
        record.errors.add(:destination, msg)
      end
    end
  end
end
