local vNIC = computer.getPCIDevices(findClass("NetworkCard"))[1]
local vDNSData = 10
local vDNSControl = 20
local vMsgPort = 30
local vLights = component.proxy(component.findComponent("LightControls"))[1]

vNIC:CloseAll()
event.clear()

---sendMsg
---Sends a formatted message to the message server for translation and forwarding to the remote machine.
---@param fDNSServer string @The UUID of the ARP server.
---@param fMsgPort number @The port the message is sent on.
---@param fDest string @The name of the remote machine you are sending the message to.
---@param fMsg string @The string of text to send to the remote machine.
function sendMsg(fDNSServer, fMsgPort, fDest, fMsg)
    local fNIC = computer.getPCIDevices(findClass("NetworkCard"))[1]
    local fNickname = tostring(fNIC.nick)
    fNIC:send(fDNSServer, fMsgPort, "Dest: " .. fDest .. ", Msg: " .. fMsg .. ", From: " .. fNickname)
    print("Msg sent!\nDest: " .. fDest .. "\nMsg: " .. fMsg)
end

---registerDNS
---@param fDNSControl number
---@param fDNSData number
function registerDNS(fDNSControl, fDNSData)
    local fNIC = computer.getPCIDevices(findClass("NetworkCard"))[1]
    fNIC:open(fDNSControl)
    local fNickname = tostring(fNIC.nick)
    fNIC:broadcast(fDNSData, fNickname)
    event.listen(fNIC)
    local fDNSComplete = false
    local fDNSServer = ""
    while fDNSComplete == false do
        ev, module, sender, pt, vMessage = event.pull()
        if vMessage == nil then
            break
        elseif vMessage == "ACK" then
            fDNSServer = sender
            fDNSComplete = true
        end
        print("ARP Complete: " .. tostring(fDNSComplete))
        print("Registered with: " .. fDNSServer)
        return fDNSServer, fDNSComplete
    end
end

---receiveMsg
---@param fDNSComplete boolean
---@param fMsgPort number
function receiveMsg(fDNSComplete, fMsgPort)
    local fNIC = computer.getPCIDevices(findClass("NetworkCard"))[1]
    local fDNSReboot = false
    fNIC:open(fMsgPort)
    while fDNSComplete == true do
        :: RestartMsgSystem ::
        print("Waiting on Message")
        ev, module, sender, pt, fMessage = event.pull()
        if fMessage == nil then
            break
        elseif string.match(fMessage, "Start:") then
            print("DNS Server cold start")
            fDNSReboot = true
            return "Empty", "Empty", fDNSReboot
        else
            _, _, fMsg, fFrom = string.find(fMessage, "(.*),From:%s(.*)")
            if fMsg == nil or fFrom == nil then
                print("Received malformed message!")
                goto RestartMsgSystem
            else
                return fFrom, fMsg, fDNSReboot
            end
        end
    end
end

:: RegisterDNS ::
local vDNSServer, vDNSComplete = registerDNS(vDNSControl, vDNSData)
--sendMsg(vDNSServer, vMsgPort, "NET1COMP1", "Test")
:: ReceiveMessage ::
local vFrom, vMsg, vDNSReboot = receiveMsg(vDNSComplete, vMsgPort)
if vDNSReboot == true then
    goto RegisterDNS
end
--if vMsg == "Light: On" then vLights.isLightEnabled = true end
--if vMsg == "Light: Off" then vLights.isLightEnabled = false end
print(vFrom .. " Sent: " .. vMsg)
goto ReceiveMessage