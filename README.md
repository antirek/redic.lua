# Redic.lua

[Redic](https://github.com/amakawa/redic) compatible Redis (wrapper) client for Lua.

This library wraps existing Redis Lua clients and provide a unified interface. As a result, in your project you can only deal with the Redic interface without bothering with the underlying implementation.

This is initially designed to work with [sohm.lua](https://github.com/xxuejie/sohm.lua), we want to make sure sohm.lua works across OpenResty and plain LuaJIT platforms.

# Supported Platforms

* [lua-resty-redis](https://github.com/openresty/lua-resty-redis)
* [resp](https://github.com/soveran/resp)

# Getting Started

Here we use [lua-resty-redis](https://github.com/openresty/lua-resty-redis) as an example, suppose we have the following code:

```lua
local redis = require "resty.redis"
local red = redis:new()

red:set_timeout(1000) -- 1 sec

-- or connect to a unix domain socket file listened
-- by a redis server:
--     local ok, err = red:connect("unix:/path/to/redis.sock")

local ok, err = red:connect("127.0.0.1", 6379)
if not ok then
    ngx.say("failed to connect: ", err)
    return
end
```

You can use Redic.lua like this:

```lua
local redic = require "redic"
local db = redic(red, "lua-resty-redis")

local res, err = db:call("GET", "dog")

if err then
    print("Error occurs: " .. err)
    return
end
ngx.say("dog: ", tostring(res))
```

You can also send pipelined requests:

```lua
db:queue("SET", "cat", "Marry")
db:queue("SET", "horse", "Bob")
db:queue("GET", "cat")
db:queue("GET", "horse")

local results, err = db:commit()

if err then
    print("Error occurs: " .. err)
    return
end

for i, res in ipairs(results) do
    if type(res) == "table" then
        if res[1] == false then
            print("failed to run command ", i, ": ", res[2])
        else
            -- process the table value
        end
    else
        -- process the scalar value
    end
end
```
