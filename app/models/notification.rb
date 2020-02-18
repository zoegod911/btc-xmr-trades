class Notification < ApplicationRecord
  jose_encrypt :message, :destination_path

  belongs_to :user
end
