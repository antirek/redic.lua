package = "redic"
version = "0.1-1"

source = {
  url = "git://github.com/antirek/redic.git",
  branch = "master"
}

description = {
  summary = "",
  homepage = "",
  maintainer = "",
  license = ""
}

dependencies = {
  "lua ~> 5.1",
  "lua-cmsgpack",
  "lsocket"
}

build = {
  type = "builtin",
  modules = {
    ["redic"] = "redic.lua",
  },
  install = {
    lua = {
      ["redic"] = "redic.lua",
    }
  }
}
