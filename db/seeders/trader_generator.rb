require 'faker'
require "#{Rails.root}/db/seeders/user_generator"

class TraderGenerator
  def self.generate!
    users = User.where(id: (1..250).to_a)

    new_user = if users.count >= 250
      users[201..250].sample
    else
      UserGenerator.generate!
    end

    wallet = WalletService.create_wallet(user_id: new_user.id)
    Trader.create(user_id: new_user.id, wallet_id: wallet.id, trust_score: 0)
  end
end
