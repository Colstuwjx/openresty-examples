local configuration = require("configuration")
local ngx_balancer = require("ngx.balancer")

local _M = {}

function _M.balance()
  local configs = configuration.get_backends_data()
  local peer = "127.0.0.1:8070"
  if configs == "a" then
    peer = "127.0.0.1:8070"
  end

  if configs == "b" then
    peer = "127.0.0.1:8080"
  end

  if not peer then
    ngx.log(ngx.WARN, "no peer was returned")
    return
  end

  ngx_balancer.set_more_tries(1)
  local ok, err = ngx_balancer.set_current_peer(peer)
  if not ok then
    ngx.log(ngx.ERR, string.format("error while setting current upstream peer %s: %s", peer, err))
  end
end

return _M
