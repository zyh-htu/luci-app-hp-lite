module("luci.controller.hp_lite", package.seeall)

function index()
    local nixio = require "nixio"
    if not nixio.fs.access("/etc/config/hp-lite") then
        return
    end
    entry({"admin", "services", "hp-lite"}, cbi("hp_lite/config"), _("hp-lite 客户端"), 60).dependent = true
    entry({"admin", "services", "hp-lite", "action"}, call("action_service")).leaf = true
end

function action_service()
    local http = require "luci.http"
    local util = require "luci.util"

    local act = http.formvalue("act")
    local cmd = ""

    if act == "start" then
        cmd = "/etc/init.d/hp-lite start"
    elseif act == "stop" then
        cmd = "/etc/init.d/hp-lite stop"
    end

    if #cmd > 0 then
        util.exec(cmd .. " >/dev/null 2>&1")
    end

    http.prepare_content("application/json")
    http.write_json({status = "ok", action = act})
end