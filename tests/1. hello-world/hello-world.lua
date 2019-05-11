-- filename: hello-world.lua
local _M = {}

function _M.hello()
    ngx.header["Content-Type"] = "text/plain";
    ngx.say("hello world");
end

return _M
