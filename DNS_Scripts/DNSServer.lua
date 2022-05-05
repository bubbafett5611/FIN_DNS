local vDNSData = 10
local vDNSControl = 20
local vMsgPort = 30
local vDNSBroadcastIn = 40
local vDNSBroadcastOut = 41

---runDNSServer
---@param fDNSData number @The client to server communication port.
---@param fDNSControl number @The server to client communication port.
---@param fMsgPort number @The client to client communication port.
function runDNSServer(fDNSData, fDNSControl, fDNSBroadcastIn, fDNSBroadcastOut, fMsgPort)
    local fNIC = computer.getPCIDevices(findClass("NetworkCard"))[1]
    computer.beep(1)
    print("DNS Server Started!")
    fNIC:closeALL()
    fNIC:open(fDNSData)
    fNIC:open(fMsgPort)
    fNIC:open(fDNSBroadcastIn)
    fNickname = tostring(fNIC.nick)
    fNIC:broadcast(fDNSControl, "Start: " .. fNickname)
    print("Broadcast sent on: " .. fDNSControl)

    event.listen(fNIC)
    fRemoteNICs = {}
    while true do
        ev, module, sender, pt, fMessage = event.pull()
        local fRemoteNIC = sender
        if fMessage == nil then
            break
        elseif string.match(fMessage, "Dest:") then
            _, _, fRemoteName, fMsg, fSendName = string.find(fMessage, "Dest:%s(.*),%sMsg:%s(.*),%sFrom:%s(.*)")
            local fLoop = true
            while fLoop == true do
                for Key, Value in pairs(fRemoteNICs) do
                    if Key == fRemoteName then
                        fRecUUID = Value
                    end
                end
                if fRecUUID == nil then
                    fNIC:Broadcast(fDNSBroadcastOut, fMessage)
                    print("Broadcast: " .. fMsg .. " To: " .. fRemoteName .. " From: " .. fSendName)
                    fLoop = false
                else
                    fNIC:send(fRecUUID, fMsgPort, fMsg .. ",From: " .. fSendName)
                    print("Sending: " .. fMsg .. " To: " .. fRemoteName .. " (" .. fRecUUID .. ") From: " .. fSendName)
                    fLoop = false
                end
            end
        else
            local fRemoteName = fMessage
            fRemoteNICs[fRemoteName] = fRemoteNIC
            fNIC:send(fRemoteNIC, fDNSControl, "ACK")
            print("Added: " .. fRemoteName .. " = " .. fRemoteNICs[fRemoteName])
        end
    end
end

runDNSServer(vDNSData, vDNSControl, vDNSBroadcastIn, vDNSBroadcastOut, vMsgPort)
