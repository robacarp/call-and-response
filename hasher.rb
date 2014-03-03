require 'openssl'

module Hasher
  class << self
    lines = File.read('config.txt').split("\n") rescue Errno::ENOENT

    if lines.nil? || ! lines.kind_of?(Array) || lines.length < 2
      puts "\033[31m WARNING: Invalid or missing config.txt, loading token bases with random data. \033[0m"
      puts "\033[31m          Clients will not be able to authenticate. \033[0m"
      lines = [SecureRandom.hex(100), SecureRandom.hex(100)]
    end

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
