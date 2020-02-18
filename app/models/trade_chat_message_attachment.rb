class TradeChatMessageAttachment < ApplicationRecord
  belongs_to :trade_chat_message

  has_many_attached :attachments
  validates :attachments, presence: true
  #
  # before_save :scan_for_viruses
  #
  # private
  #
  # def scan_for_viruses
  #   files = self.attachment_changes['attachments'].try(:attachables)
  #   return unless files.present?
  #
  #   files.all? { |file| Clamby.safe?(file.tempfile.path) }
  # end
end
