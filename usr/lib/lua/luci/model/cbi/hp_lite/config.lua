local uci = require "luci.model.uci".cursor()
local util = require "luci.util"
local sys = require "luci.sys"

local m = Map("hp-lite", translate(""))

local s = m:section(NamedSection, "global", "hp-lite", translate("General Settings"))

local running = (sys.call("pgrep -f 'hp-lite' >/dev/null") == 0)
local status = s:option(DummyValue, "_status", translate("运行状态"))
status.rawhtml = true
status.value = running and "<b style='color:green'>Running</b>" or "<b style='color:red'>Stopped</b>"

local connect = s:option(Value, "connect_code", translate("连接码"))
connect.placeholder = "connection code"

local start_btn = s:option(Button, "_start", translate("启动服务"))
start_btn.inputstyle = "apply"
function start_btn.write()
    util.exec("/etc/init.d/hp-lite start >/dev/null 2>&1")
    luci.http.redirect(luci.dispatcher.build_url("admin/services/hp-lite"))
end

local stop_btn = s:option(Button, "_stop", translate("停止服务"))
stop_btn.inputstyle = "reset"
function stop_btn.write()
    util.exec("/etc/init.d/hp-lite stop >/dev/null 2>&1")
    luci.http.redirect(luci.dispatcher.build_url("admin/services/hp-lite"))
end

function m.on_after_apply(self, map)
    util.exec("uci commit hp-lite")
end
return m