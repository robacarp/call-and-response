require 'openssl'

module Hasher
  class << self
    lines = File.read('config.txt').split("\n")
    SALT = lines[0]
    PEPPER = lines[1]

    def salt
      OpenSSL::Digest::SHA256.hexdigest(SALT + Time.now.to_s)
    end

    def pepper salted
      OpenSSL::Digest::SHA512.hexdigest( salted.to_s + PEPPER )
    end
  end
end
