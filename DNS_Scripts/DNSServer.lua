--[[
By: Bubbafett5611
Version: 0.0.1
Date: 2022/05/05
]]--
---runDNSServer
---@param DataPort number @Client to server communication port.
---@param ControlPort number @Server to client communication port.
---@param BroadcastInPort number @Server to server inbound port.
---@param BroadcastOutPort number @Server to server outbound port.
---@param MessagePort number @Port for handling messages.
function runDNSServer(DataPort, ControlPort, BroadcastInPort, BroadcastOutPort, MessagePort)
    local NIC = computer.getPCIDevices(findClass("NetworkCard"))[1]
    computer.beep(1)
    print("DNS Server Started!")
    NIC:closeALL()
    NIC:open(DataPort)
    NIC:open(MessagePort)
    NIC:open(BroadcastInPort)
    local Nickname = tostring(NIC.nick)
    NIC:broadcast(ControlPort, "Start: " .. Nickname)
    print("Broadcast sent on: " .. ControlPort)

    event.listen(NIC)
    RemoteNICs = {}
    while true do
        ev, module, sender, pt, MessageIn = event.pull()
        local RemoteNIC = sender
        if MessageIn == nil then
            break
        elseif string.match(MessageIn, "Dest:") then
            _, _, RemoteName, Message, SendName = string.find(MessageIn, "Dest:%s(.*),%sMsg:%s(.*),%sFrom:%s(.*)")
            local Loop = true
            while Loop == true do
                for Key, Value in pairs(RemoteNICs) do
                    if Key == RemoteName then
                        RecUUID = Value
                    end
                end
                if RecUUID == nil then
                    NIC:Broadcast(BroadcastOutPort, MessageIn)
                    print("Broadcast: " .. Message .. " To: " .. RemoteName .. " From: " .. SendName)
                    Loop = false
                else
                    NIC:send(RecUUID, MessagePort, Message .. ",From: " .. SendName)
                    print("Sending: " .. Message .. " To: " .. RemoteName .. " (" .. RecUUID .. ") From: " .. SendName)
                    Loop = false
                end
            end
        else
            local RemoteName = MessageIn
            RemoteNICs[RemoteName] = RemoteNIC
            NIC:send(RemoteNIC, ControlPort, "ACK")
            print("Added: " .. RemoteName .. " = " .. RemoteNICs[RemoteName])
        end
    end
end