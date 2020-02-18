require 'faker'
require 'securerandom'

class UserGenerator
  def self.generate!(username: Faker::Internet.unique.username, role: nil)
    pubkey = "-----BEGIN PGP PUBLIC KEY BLOCK-----

    mQENBF0k2FwBCAChTe/ELEzII7pU1J+yzbP48dcXwyKPOLFDte65wkXs6xIn6IjM
    gTJ9eoZ1T4ABIMOdvBkTdLXlPXr80GUm93/6PNuLqZONjVmDnaOA2yXwk9LPnIP0
    IBIPOUE6j3kU/LpU9SGFYLMGmIrYdeSchRkUYzZ/zLhH5i/HjVTClZD74SVitu7X
    Jd+XxhsvukeUFvXJ0tsXXp80aEuLCc8VZ4X31QIRz9xv6ViG2w/UUT3TUqOD7yUM
    7H8BJZR0EYOThIkahZW4mMMiVtIEebXf5ekVt1Shcl5CfxH7q7Sfn5PaRBJz/IS5
    ZJ9OFWJIoqvDlyvhnOrYJiKO+CQ4k8AXABqbABEBAAG0JmxlZnJha21hYyA8em9l
    Z2F3ZDEzMzdAcHJvdG9ubWFpbC5jb20+iQFUBBMBCAA+FiEE5xX5EaNFqDz2QI6O
    dND5FxHNffMFAl0k2FwCGwMFCQPDxFQFCwkIBwIGFQoJCAsCBBYCAwECHgECF4AA
    CgkQdND5FxHNffMuAwf+KmWnjtTcv7X9i3ONG6JDYjjpPhFHDw3USHxBU2j/cwlR
    JQ3c+uDHiE83kP6BExt22GeM0uszIWV0kpF2BHwwcEu0dkwVP6mvtaRdfmJFpSuF
    YY/OUO+6jXoZbaw/FYJkCfR9icLCL/eK5YGf9y8Se8ywDHHQ04XsyuBShfSFqO15
    mACRppSxQEMrApgAxRYU6PMlwPe6LsoFSrf9381JpQpAdk5Yi/AQecW0mmW5fxNz
    WUEynDjVrTsbs/tnXttbAYtpVoApUg7Q5E9W3Bbp4trJR/Cp7LzBOV8LtXZeyuRy
    zw2t0InvGkS/YHMDQsuH1SbhBO2jT+TFegjlQ0zXO7kBDQRdJNhcAQgA4PU5V93w
    HFK2EZtcukUnvyIC/8eNUe8epaSIFkwDDGVkIssi0VFesprD7UPq5zh2iOeLA+Hr
    LjGDhVF2F9Qzu16fn+H6Gl595nhjkGsbd4AHDy22TkkfqYgwXb2xKXVyWF7Pvo9U
    aig/qLRl7Htknb6J40BduC4ZYX5+XK6Qac6/LLGuiNKC09lh6Mgt+vQcbSvY1WQ3
    wxnDB5u4IE78fYOkHkNUyS3vI8eRpaAkewxv/pTj84FCszedorjo4G/Ls2GREOXD
    1ACpja0apvVz0p2KHlFtWlr7QAVV0GNJ4ruVUOfqC0nKWpd6zjg6/wwJqNkJjePR
    wkrLHgLYsgDtSwARAQABiQE8BBgBCAAmFiEE5xX5EaNFqDz2QI6OdND5FxHNffMF
    Al0k2FwCGwwFCQPDxFQACgkQdND5FxHNffO1eQf8C+qPb3q0T1SA3vMI/UwWzdT0
    08QLBOi/Q4kitsMWPorJlKqsUwp6O0elKpq90+q8S9mipZ1u1bkvpRX+7mLOEWKP
    talI7FChDhBQPM/SxcgxD3io5AGU7AkIVOI7YNQduiTEa7tr49/UfYcob1rarKkA
    13tEQBsBE8THLk/1rHlBMSwgZNwRI4qDDPmh3BLyVIhC+QIIoyY0ePSw0b5NZOvc
    brR941L0XHSqEAif2eWIvLjXZbWw7eGjpLf+YotmAAgb84jnluyNN8FfjiREhL+o
    +Ci9ADSEYHSc4pU2DdLrfWA2YfUDSms/bL2KKJdtpmmPV/sizI6kmzmPx4pn4Q==
    =jPC/
    -----END PGP PUBLIC KEY BLOCK-----"

    pass = Faker::Internet.unique.password + SecureRandom.base64(21)
    user = User.new(
      username: username,
      pgp_public_key: pubkey,
      password: pass,
      password_confirmation: pass,
      mnemonic: BipMnemonic.to_mnemonic(bits: 128),
    )
    # user.textcaptcha
    #
    # question =  CAPTCHA_QUESTIONS.filter do |h|
    #   h[:question] == user.textcaptcha_question
    # end[0]
    # answer = question[:answers].split(',')[0]

    # user.textcaptcha_answer = answer

    login_date = (DateTime.now - 30..DateTime.now).to_a.sample

    user.last_login_at = login_date
    user.last_logout_at = login_date - 7
    user.last_activity_at = login_date + 30.minutes

    user.default_currency = 'USD' # CURRENCIES.sample
    # user.default_cryptocurrency = %w(BTC LTC XMR).sample

    user.role = role if role

    user.save!

    user
  end
end
