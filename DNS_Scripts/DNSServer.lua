--[[
By: Bubbafett5611
Version: 0.0.4d
Date: 2022/05/05
]]--

function prepareServer(DataPort, ControlPort, MessagePort, BroadcastInPort)
    DataPort = DataPort or 54
    ControlPort = ControlPort or 53
    MessagePort = MessagePort or 25
    BroadcastInPort = BroadcastInPort or 20

    NIC = computer.getPCIDevices(findClass("NetworkCard"))[1]

    NIC:closeALL()
    NIC:open(DataPort)
    NIC:open(MessagePort)
    NIC:open(BroadcastInPort)
    Nickname = tostring(NIC.nick)

    event.listen(NIC)
    RemoteNICs = {}
end

---runDNSServer
---@param BroadcastOutPort number @Server to server outbound port.
---@param MessagePort number @Port for handling messages.
function handleMessage(BroadcastOutPort, MessagePort)
    ev, module, sender, pt, MessageIn = event.pull()
    local UUID = sender
    local NewClient = true
    if MessageIn == nil then
        computer.stop()
    elseif string.match(MessageIn, "Dest:") then
        _, _, RemoteName, Message, SendName = string.find(MessageIn, "Dest:%s(.*),%sMsg:%s(.*),%sFrom:%s(.*)")
        for Key, Value in pairs(RemoteNICs) do
            if Key == RemoteName then
                RecUUID = Value
            end
        end
        if RecUUID == nil then
            NewClient = false
            NIC:Broadcast(BroadcastOutPort, MessageIn)
            print("Broadcast: " .. Message .. " To: " .. RemoteName .. " From: " .. SendName)
        else
            NewClient = false
            NIC:send(RecUUID, MessagePort, Message .. ",From: " .. SendName)
            print("Sending: " .. Message .. " To: " .. RemoteName .. " (" .. RecUUID .. ") From: " .. SendName)
        end
    else
        local Nickname = MessageIn
        NewClient = true
        return UUID, Nickname, NewClient
    end
end

function registerClients(NewClient,UUID, Nickname, ControlPort, PrintLog)
    if NewClient == true then
        if UUID == nil then
            computer.beep(1)
            print("Error: Missing parameter (pos1): UUID")
            computer.stop()
        elseif Nickname == nil then
            computer.beep(1)
            print("Error: Missing parameter (pos2): Nickname")
            computer.stop()
        end
        ControlPort = ControlPort or 53
        PrintLog = PrintLog or true
        RemoteNICs[Nickname] = UUID
        NIC:send(UUID, ControlPort, "ACK")
        if PrintLog == true then
            print("Added: " .. Nickname .. " = " .. RemoteNICs[Nickname])
        end
    end
end