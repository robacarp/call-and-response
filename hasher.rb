require 'openssl'
require 'SecureRandom'

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

    def randomish
      SecureRandom.hex(
        Integer (SecureRandom.random_number * 1000 + 10)
      )
    end

    def salt
      OpenSSL::Digest::SHA256.hexdigest(SALT + Time.now.to_s + randomish)
    end

    def pepper salted
      OpenSSL::Digest::SHA512.hexdigest( salted.to_s + PEPPER )
    end
  end
end
