class RegistrationsController < ApplicationController
  def new
  end

  def create
    user_attrs = user_params.to_h
    user_attrs.merge!(mnemonic: BipMnemonic.to_mnemonic(bits: 128))

    @user = User.new(user_attrs)

    if @user.save
      @wallet = WalletService.create_wallet(user_id: @user.id)
      Trader.create!(wallet_id: @wallet.id, user_id: @user.id)

      redirect_to new_session_path, flash: {
        success: "#{@user.username} has registered. You may now log in."
      }
    else
      redirect_to new_registration_path, flash: {
        error: @user.errors.messages.map {|k, v| "#{k} #{v[0]}" }
      }
    end
  end

  private

  def user_params
    params.require(:user).permit(
      :username, :password, :password_confirmation, :pgp_public_key,
      :password, :password_confirmation
    )
  end
end
