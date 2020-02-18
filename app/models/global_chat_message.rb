class GlobalChatMessage < ApplicationRecord
  belongs_to :global_chat
  belongs_to :sender, class_name: 'Trader'


  jose_encrypt :content
end
