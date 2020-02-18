require 'faraday'
require 'faraday_middleware'
require 'faraday_adapter_socks'

class CaptchaService
  def self.valid?(captcha_id)
    url = "#{CAPTCHA_WORKER}/validate"
    opts = {
      proxy: { uri: URI.parse('socks://127.0.0.1:9050') },
      request: { timeout: 1000, open_timeout: 1000 }
    }

    conn = Faraday.new(url, opts) do |f|
      f.use       FaradayMiddleware::FollowRedirects, limit: 5
      f.adapter   :net_http_socks
      f.request   :retry, max: 10
    end

    post_data = URI.encode_www_form({ c_id: captcha_id })

    res = conn.post('/validate', post_data).body

    valid = parse_response(res)

    return true if valid.success
    return false if valid.error
  end


  def self.parse_response(response)
    response = JSON.parse(response, object_class: OpenStruct)
  end
end
