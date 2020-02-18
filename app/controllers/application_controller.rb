class ApplicationController < ActionController::Base
  before_action :throttle_sessions, :require_captcha

  def require_login
    unless current_user
      redirect_to new_session_path, flash: {
        notice: 'You have been logged out.'
      }
    end
  end

  def require_2fa
    unless session[:two_fa_validated]
      redirect_to two_factor_authorization_path
      return
    end
  end

  def require_captcha
    db_session = Session.find_by(session_id: session.id)

    return if db_session.passed_captcha?
    unless params[:passed_captcha]
      render json: { error: 'ddos prevention' }, status: 444
      return
    end

    valid_captcha = CaptchaService.valid?(params[:passed_captcha])
    if valid_captcha
      db_session.update(passed_captcha: true)
    else
      render json: { error: 'ddos prevention' }, status: 444
    end
  end

  private

  def throttle_sessions
    puts "SESSION: #{session.id}"
    db_session = Session.find_by(session_id: session.id)

    db_session.ddos_check
    if db_session.throttled?
     render file: 'public/502.html', status: 502, layout: false
    end

    if db_session.blocklisted?
     render file: 'public/500.html', status: 500, layout: false
    end
  end
end
