-- filename: configuration.lua
local _M = {}
local configuration_data = ngx.shared.configuration_data

local function fetch_request_body()
  ngx.req.read_body()
  local body = ngx.req.get_body_data()

  if not body then
    -- request body might've been written to tmp file if body > client_body_buffer_size
    local file_name = ngx.req.get_body_file()
    local file = io.open(file_name, "rb")

    if not file then
      return nil
    end

    body = file:read("*all")
    file:close()
  end

  return body
end

function _M.get_backends_data()
  if not configuration_data then
    return nil
  end
  return configuration_data:get("backends")
end

function _M.call()
  if ngx.var.request_method ~= "POST" and ngx.var.request_method ~= "GET" then
    ngx.status = ngx.HTTP_BAD_REQUEST
    ngx.header["Content-Type"] = "text/plain";
    ngx.say("Only POST and GET requests are allowed!")
    return
  end

  if ngx.var.request_method == "GET" then
    ngx.status = ngx.HTTP_OK
    ngx.header["Content-Type"] = "text/plain";
    ngx.say(_M.get_backends_data())
    return
  end

  local backends = fetch_request_body()
  if not backends then
    ngx.log(ngx.ERR, "dynamic-configuration: unable to read valid request body")
    ngx.status = ngx.HTTP_BAD_REQUEST
    return
  end

  local success, err = configuration_data:set("backends", backends)
  if not success then
    ngx.log(ngx.ERR, "dynamic-configuration: error updating configuration: " .. tostring(err))
    ngx.status = ngx.HTTP_BAD_REQUEST
    return
  end

  ngx.status = ngx.HTTP_CREATED
end

return _M
