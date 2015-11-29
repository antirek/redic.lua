local resty_call = function(self, cmd, ...)
  return self._db[string.lower(cmd)](self._db, ...)
end

local resty_queue = function(self, cmd, ...)
  self._queue[#self._queue + 1] = {cmd = cmd, args = {...}}
end

local resty_commit = function(self)
  self._db:init_pipeline()
  for _, command in ipairs(self._queue) do
    self._db[string.lower(command.cmd)](self._db, unpack(command.args))
  end
  self._queue = {}
  return self._db:commit_pipeline()
end

local providers = setmetatable({}, {
    __index = function (t, k)
      error("provider '" .. k .. "' is unimplemented")
    end
})

providers["lua-resty-redis"] = {
  call = resty_call,
  queue = resty_queue,
  commit = resty_commit
}

local deduct_provider = function(db, provider)
  if provider then return provider end
  if type(db.init_pipeline) == "function" then
    return "lua-resty-redis"
  elseif type(db.call) == "function" and type(db.queue) == "function" then
    return "resp"
  end
end

local new = function(db, provider)
  provider = deduct_provider(db, provider)
  if not provider then return "", "No provider is specified!" end
  -- Resp needs no wrapper
  if provider == "resp" then return db end

  local self = {}
  self._db = db
  self._queue = {}
  setmetatable(self, {__index = providers[provider]})
  return self
end

return {
  new = new
}
