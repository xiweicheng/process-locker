
-- KEYS[1] target key
-- KEYS[2] key prefix
-- ARGV[1] convert result
-- ARGV[2] result time out

local key = KEYS[1]
local channel = KEYS[2]
local value = ARGV[1]
local timeout = ARGV[2]

redis.call('PSETEX', key, timeout, value)
local result = redis.call('PUBLISH', channel, cjson.encode({key=key, value=value}))

return result