# frozen_string_literal: true
require "#{Rails.root}/app/serializers/jose_encryption"


if defined?(ActiveRecord::Base)
  module Jose
    module Model
      module ActiveRecord

        protected

        # <tt>attr_encrypted</tt> method
        def jose_encrypt(*attrs)
          define_method :encrypted_columns do
            attrs
          end

          attrs.each do |attr|
            # Get attributes as encrypted
            define_method("raw_#{attr}") do
              value = read_attribute(attr)
            end

            # Get as decrypted attribute
            define_method(attr) do
              value = read_attribute(attr)
              exit_early = attribute_changed?(attr) || self.new_record? || value.nil?

              return value if exit_early

              ::JoseEncryption.decrypt_cipher(attr, value)
            end

            define_method("#{attr}=") do |value|
              write_attribute(attr, value)
            end
          end

          define_method :encrypt_jose_columns do
            new_changes = self.changed_attributes

            new_changes.each do |column_name, value|
              if self.encrypted_columns.include?(column_name.to_sym)
                v = self.send(column_name)
                next if v.nil?

                encrypted = ::JoseEncryption.encrypt_attribute(column_name, v)

                self.write_attribute(column_name, encrypted)
              end
            end
          end

          private :encrypt_jose_columns

          self.before_save :encrypt_jose_columns, if: proc { |record|
            record.changed_attributes.keys.length > 0
          }
        end
      end
    end
  end
end
