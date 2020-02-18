class PgpPublicKeyValidator < ActiveModel::Validator
  def validate(record)
    key = record.pgp_public_key
    pgp_message = PgpMessenger.encrypt_message(
      pgp_public_key: key,
      message: 'TEST'
    )

    unless pgp_message
      record.errors.add(:pgp_public_key, "Invalid PGP Public Key provided...")
    end
  end
end
