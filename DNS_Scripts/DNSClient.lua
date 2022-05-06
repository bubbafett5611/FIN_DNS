--[[
By: Bubbafett5611
Version: 0.0.1
Date: 2022/05/05
]]--
---sendMessage
---Sends a formatted message to the message server for translation and forwarding to the remote machine.
---@param DNSServer string @The UUID of the ARP server.
---@param Port number @The port the message is sent on.
---@param Destination string @The name of the remote machine you are sending the message to.
---@param Message string @The string of text to send to the remote machine.
function sendMessage(DNSServer, Port, Destination, Message)
    local NIC = computer.getPCIDevices(findClass("NetworkCard"))[1]
    local Nickname = tostring(NIC.nick)
    NIC:send(DNSServer, Port, "Dest: " .. Destination .. ", Msg: " .. Message .. ", From: " .. Nickname)
    print("Msg sent!\nDest: " .. Destination .. "\nMsg: " .. Message)
end

---registerClient
---@param ControlPort number
---@param DataPort number
---@return table
function registerClient(ControlPort, DataPort)
    local NIC = computer.getPCIDevices(findClass("NetworkCard"))[1]
    NIC:open(ControlPort)
    local Nickname = tostring(NIC.nick)
    NIC:broadcast(DataPort, Nickname)
    event.listen(NIC)
    local DNSComplete = false
    local DNSServer = ""
    while DNSComplete == false do
        ev, module, sender, pt, Message = event.pull()
        if Message == nil then
            break
        elseif Message == "ACK" then
            DNSServer = sender
            DNSComplete = true
        end
        print("ARP Complete: " .. tostring(DNSComplete))
        print("Registered with: " .. DNSServer)
        return DNSServer, DNSComplete
    end
end

---receiveMsg
---The computer MUST be registered with the DNS server BEFORE it can receive messages.
---@param DNSComplete boolean
---@param Port number
---@return table
function receiveMsg(DNSComplete, Port)
    local NIC = computer.getPCIDevices(findClass("NetworkCard"))[1]
    local DNSReboot = false
    NIC:open(Port)
    while DNSComplete == true do
        :: RestartMsgSystem ::
        print("Waiting on Message")
        ev, module, sender, pt, MessageIn = event.pull()
        if MessageIn == nil then
            break
        elseif string.match(MessageIn, "Start:") then
            print("DNS Server cold start")
            DNSReboot = true
            return "Empty", "Empty", DNSReboot
        else
            _, _, Message, From = string.find(MessageIn, "(.*),From:%s(.*)")
            if Message == nil or From == nil then
                print("Received malformed message!")
                goto RestartMsgSystem
            else
                return From, Message, DNSReboot
            end
        end
    end
end