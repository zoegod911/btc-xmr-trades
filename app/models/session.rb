class Session < ApplicationRecord
  jose_encrypt :data

  def ddos_check
    unless 15.seconds.ago > self.last_request_at
      self.offensive_requests += 1

      puts "THROTTLED: #{self.throttled}"
      puts "BLOCKED: #{self.blocklisted}"
      puts "OFFENSIVE REQUESTS: #{self.offensive_requests}"

      if self.offensive_requests >= 20 && self.offensive_requests < 30
        self.throttled = true
        self.blocklisted = false
      elsif self.offensive_requests >= 30
        self.throttled = false
        self.blocklisted = true
      end
    else
      self.offensive_requests = 0
      self.throttled = false unless unthrottled?
      self.blocklisted = false unless unblocklisted?
    end

    self.last_request_at = DateTime.now
    self.save!
  end

  def unthrottled?
    self.throttled == false || 15.seconds.ago < self.last_request_at
  end

  def unblocklisted?
    self.blocklisted == false || 1.hour.ago < self.last_request_at
  end

end
