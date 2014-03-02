require 'sinatra'
require 'debugger'
require 'redis'

load 'hasher.rb'

EXPIRE = 3

configure do
  REDIS = Redis.new host: 'localhost', port: 6379
end

def key hash
  key = "dyndns:#{hash}"
end

get '/' do
  hash = Hasher.salt

  # store the hash in redis,
  # set it to expire in 3 seconds
  REDIS.set key(hash), Time.now.to_i
  REDIS.expire key(hash), EXPIRE

  headers "X-Hash-Me" => hash
  status 200
  'ok'
end

post '/' do
  call = params['call']
  response = params['response']

  if call.nil? || call.length != 64
    status 419
    return 'not ok 1 - call mismatch'
  end

  if response.nil? || response.length != 128
    status 419
    return 'not ok 2 - response invalid'
  end

  valid = REDIS.get(key(call))
  if valid.nil?
    status 419
    return 'not ok 3 - call expired'
  end

  valid = valid.to_i
  delta = Time.now.to_i - valid

  if delta > EXPIRE
    status 419
    return 'not ok 4 - call expired'
  end

  if response != Hasher.pepper(call)
    status 419
    return 'not ok 5 - response mismatch'
  end

  status 200
  "ok 1 - everything went better than expected"
end
