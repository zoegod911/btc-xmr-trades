class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token, :require_captcha, only: :passed_captcha

  def new; end

  def create
    @user =  User.find_by_username(login_params[:username])

    if @user && login(@user.username, login_params[:password])
      reset_session


      login(@user.username, login_params[:password])
      db_session = Session.find_orcreate_by(session_id: session.id)
      db_session.update(passed_captcha: true)

      redirect_to two_factor_authorization_path, flash: {
        success: "'#{@user.username}' has signed in."
      }
    else
      redirect_to root_path, flash: {
        error: "No user found with those credentials... Try again."
      }
    end
  end

  def log_out
    username = current_user.username

    logout

    redirect_to root_path, flash: {
      notice: "#{username} has logged out."
    }
  end

  def two_factor_authorization
    pass = Rails.cache.fetch("2FA_LOGIN[#{current_user.id}][passphrase]")
    @secure_code = Rails.cache.fetch("2FA_LOGIN[#{current_user.id}][key]") {
      SecureRandom.base64(33)
    }

    current_url = "#{request.protocol}#{request.host}"
    msg = "Welcome to Pangolin. You are currently browsing on: #{current_url}.\n\n"
    msg += "BEWARE: If this URL doesn't match the URL in your address bar, you are on a phishing site.\n\n"
    msg += "This is your security code to login to the site: #{@secure_code}"

    @message = PgpMessenger.encrypt_message(
      pgp_public_key: current_user.pgp_public_key,
      message: msg
    )
  end

  def validate_2fa
    @secure_code = Rails.cache.fetch("2FA_LOGIN[#{current_user.id}][key]")

    Rails.cache.delete("2FA_LOGIN[#{current_user.id}][passphrase]")
    Rails.cache.delete("2FA_LOGIN[#{current_user.id}][key]")

    username = current_user.username
    if params[:security_code] == @secure_code
      session[:two_fa_validated] = true

      redirect_to root_path, flash: {
        success: "#{username} has successfully logged in."
      }
    else
      logout

      redirect_to root_path, flash: {
        error: "2FA Failed: #{username} has logged out."
      }
    end
  end

  def passed_captcha
    captcha = params[:c_id]

    if CaptchaService.valid?(captcha)
      cookies[:captcha] = {
        value: captcha,
        domain: request.host,
        expires: 1.year.from_now,
        httponly: false,
        secure: false
      }

      render json: { success: 'Captcha Completed.' }
    else
      render json: { error: 'error' }
    end
  end


  private

  def login_params
    params.require(:login).permit(:username, :password)
  end
end
