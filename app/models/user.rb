class User < ApplicationRecord
  authenticates_with_sorcery!

  jose_encrypt  :pgp_public_key, :mnemonic, :salt, :crypted_password

  enum role: %i(user admin moderator)
  enum default_currency: CURRENCIES

  has_one   :trader

  has_many  :sent_messages,     class_name: 'Message',  foreign_key: :sender_id, dependent: :destroy
  has_many  :received_messages, class_name: 'Message',  foreign_key: :receiver_id, dependent: :destroy

  validates_with PgpPublicKeyValidator
  validates :password,
    password_strength: true,
    allow_nil: false,
    presence: true,
    on: :create,
    length: { maximum: 255 },
    if: -> { new_record? || changes[:crypted_password] }
  validates :password, confirmation: true, if: -> { new_record? || changes[:crypted_password] }
  validates :password_confirmation, presence: true, if: -> { new_record? || changes[:crypted_password] }

  validates :username, presence: true, uniqueness: true


  def notifications
    Notification.where(user_id: self.id, seen: false)
  end

  def authority?
    %w(admin moderator).include? self.role
  end

  # Admin class methods

  def self.currently_online
    from_mins_ago = 30.minutes.ago.change(sec: 0)
    to_mins_ago   = from_mins_ago.change(sec: 59)

    self.where(last_activity_at: from_mins_ago..to_mins_ago)
  end

  def self.logged_in_today
    self.where(last_login_at: Date.today.all_day)
  end
end
