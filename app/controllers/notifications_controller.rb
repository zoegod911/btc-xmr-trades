class NotificationsController < ApplicationController
  def show
    @notification = Notification.find(params[:id])

    if @notification.update(seen: true)
      flash = {}
      if @notification.message
        flash.merge!(success: @notification.message)
      end

      redirect_to @notification.destination_path, flash: flash
    else
      redirect_to root_path
    end
  end
end
