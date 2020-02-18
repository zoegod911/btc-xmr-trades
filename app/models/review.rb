class Review < ApplicationRecord
  jose_encrypt :content

  belongs_to :trade

  belongs_to :reviewer, class_name: 'Trader', foreign_key: :reviewer_id
  belongs_to :reviewee, class_name: 'Trader', foreign_key: :reviewee_id

  def calculate_trust_score!
    current_score = reviewee.trust_score

    if self.trusted?
      self.reviewee.update!(trust_score: current_score + 1)
    else
      self.reviewee.update!(trust_score: current_score - 1)
    end
  end

  def username
    letters = self.reviewer.username.split('')
    "#{letters.sample}***#{letters.sample}"
  end
end
