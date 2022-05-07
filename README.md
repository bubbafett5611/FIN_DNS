# FicsIt-Networks DNS
![GitHub contributors](https://img.shields.io/github/contributors/bubbafett5611/FIN_DNS)
![GitHub forks](https://img.shields.io/github/forks/bubbafett5611/FIN_DNS)
![GitHub issues](https://img.shields.io/github/issues/Bubbafett5611/FIN_DNS)
![GitHub](https://img.shields.io/github/license/Bubbafett5611/FIN_DNS)

---

### Table of Content

- [About FicsIt-Networks DNS](#about-ficsit-networks-dns)
    * [Introduction](#introduction)
    * [Prerequisites](#prerequisites)
    * [Installation](#installation)
        + [DNS Server Installation](#dns-server-installation)
        + [DNS Client Installation](#dns-client-installation)
            - [Downloading and installing the file:](#downloading-and-installing-the-file)
            - [Launch and Register Clients:](#launch-and-register-clients)
    * [Functions](#functions)
        + [DNS Server Functions](#dns-server-functions)
        + [DNS Client Functions](#dns-client-functions)

---

# About FicsIt-Networks DNS

## Introduction

FicsIt-Networks DNS is a group of functions to provide DNS like services to the computers in the mod FicsIt-Networks.
The main focus of this project is to allow network computers to communicate with each other without the need to manually
identify each NICs UUID.

> **Current Versions:**  
> **DNS Server:** ``0.0.1``  
> **DNS Client:** ``0.0.1``

---

## Prerequisites

In order to use FicsIt-Networks DNS you will need the following components in your network of computers.

1. **DNS Server (Computer Case)**  
> A computer running the DNS Server script found within ``FIN_DNS/DNS_Scripts/`` in this Repo.
> DNS servers collect the **nicknames** and **UUIDs** of DNS clients into an array so that clients
> can send messages using only nicknames.
   - **Limited to 1 per network**
   - **Required components:**
     - 1 CPU T1 (Lua)
     - 1 Ram T1
     - 1 Network Card
     - 1 Internet Card
     - 1 Lua EEPROM
2. **DNS Client (Computer Case)**
> A computer running the DNS Client script found within ``FIN_DNS/DNS_Scripts/`` in this Repo.
> DNS clients will register with the DNS server so that other clients can send it messages easier.
> These computers have a custom message handling system to allow sending via nickname.
- **Requires at least one per network** (Limit per network has not been tested)
- **Required components:**
    - 1 CPU T1 (Lua)
    - 1 Ram T1
    - 1 Network Card
    - 1 Internet Card
    - 1 Lua EEPROM
3. **Network Router**
> Used to connect multiple networks together. As of writing this, there is no automatic configuration
> of routers however it is planned as a function of the DNS servers.
- **Required to connect multiple networks together**
- **Communication between networks currently uses ports and broadcast messages**

---

## Installation

As of now, the clients and servers have two different installation files however a simpler installation method is being tested.

### DNS Server Installation

DNS server installation is as simple as downloading and installing the DNSServer.lua script
and installing it to a temporary file system, then running the launch function.

**Downloading and installing the file:**
Installing the files this way allows you to receive updates to your files as computers reboot.
```lua
local card = computer.getPCIDevices(findClass("FINInternetCard"))[1]
local req = card:request("https://raw.githubusercontent.com/bubbafett5611/FIN_DNS/main/DNS_Scripts/DNSServer.lua", "GET", "")

filesystem.initFileSystem("/dev")
filesystem.makeFileSystem("tmpfs", "tmp")
filesystem.mount("/dev/tmp","/")
local file = filesystem.open("DNSServer.lua", "w")
file:write(DNSServer)
file:close()
```

**Launch the DNS Server:**
As of now, DNS servers only have a single function that handles all of their task. I plan on splitting this
to allow for more control over functionality.
```lua
--Port numbers can be changed to suite your needs, however I have not tested reusing ports in the same network.
local DataPort = 10
local ControlPort = 20
local BroadcastInPort = 40
local BroadcastOutPort = 41
local MsgPort = 30

--RUN DNS SERVER INSTALLATION HERE

runDNSServer(DataPort, ControlPort,BroadcastInPort,BroadcastOutPort, MsgPort)
```

---

### DNS Client Installation

DNS server installation is as simple as downloading and installing the DNSServer.lua script
and installing it to a temporary file system, then running the launch function.

#### Downloading and installing the file
Installing the files this way allows you to receive updates to your files as computers reboot.
```lua
local card = computer.getPCIDevices(findClass("FINInternetCard"))[1]
local req = card:request("https://raw.githubusercontent.com/bubbafett5611/FIN_DNS/main/DNS_Scripts/DNSClient.lua", "GET", "")

filesystem.initFileSystem("/dev")
filesystem.makeFileSystem("tmpfs", "tmp")
filesystem.mount("/dev/tmp","/")
local file = filesystem.open("DNSClient.lua", "w")
file:write(DNSClient)
file:close()
```

#### Launch and Register Clients
This example shows how to register clients with the server, send a message, then waits on messages to print.
```lua
--Port numbers can be changed to suite your needs, however I have not tested reusing ports in the same network.
local DataPort = 10
local ControlPort = 20
local MsgPort = 30
local Nickname = "Net1_Comp1" --Computer Network Cards must have unique names within connected networks
local MsgSent = "This is a test message"

--RUN DNS CLIENT INSTALLATION HERE

:: RegisterDNS ::
local DNSServer, DNSComplete = registerClient(ControlPort, DataPort)
sendMessage(DNSServer, MsgPort, Nickname, MsgSent)
:: ReceiveMessage ::
local From, MsgRec, DNSReboot = receiveMsg(DNSComplete, MsgPort)
if DNSReboot == true then
    goto RegisterDNS
end
print(From .. " Sent: " .. MsgRec)
goto ReceiveMessage
```

---

## Functions

As of now, no parameters are optional. Optional parameters are under active development and will be updated.

### DNS Server Functions
As of now the DNS Server only has one function. I plan on splitting this function into multiple functions
to allow for greater control and customization.

> **runDNSServer(``DataPort``, ``ControlPort``, ``BroadcastInPort``, ``BroadcastOutPort``, ``MessagePort``)**  
>
> This function runs the DNS server completely and is required for all networks to function correctly.
> - **Param:** ``DataPort`` **Type:** ``number`` Client to server communication port.
> - **Param:** ``ControlPort`` **Type:** ``number`` Server to client communication port.
> - **Param:** ``BroadcastInPort`` **Type:** ``number`` Server to server inbound port.
> - **Param:** ``BroadcastOutPort`` **Type:** ``number`` Server to server outbound port.
> - **Param:** ``MessagePort`` **Type:** ``number`` Port for handling messages.
>
>***This function currently prints all returns to console.***

### DNS Client Functions
There are currently three client functions. One for registering the client, one for sending message,
and one for receiving messages.

> **registerClient(``ControlPort``, ``DataPort``)**
> 
> This function registers the client with the DNS server on the network using the same ports as it.
> - **Param:** ``ControlPort`` **Type:** ``number`` Server to client communication port.
> - **Param:** ``DataPort`` **Type:** ``number`` Client to server communication port.
> ---
> - **Return:** ``DNSServer`` **Type:** ``string`` The name of the DNS server that responded and registered the client.
> - **Return:** ``DNSComplete`` **Type:** ``boolean`` Must be passed to the ``receiveMsg()`` function.

> **sendMessage(``DNSServer``, ``Port``, ``Destination``, ``Message``)**
> 
> This function sends a message to the remote client using that client nickname rather than UUID.
> - **Param:** ``DNSServer`` **Type:** ``string`` The UUID of the ARP server, can be passed from the ``registerClient()`` function.
> - **Param:** ``Port`` **Type:** ``number`` The port the message is sent on, should be the same port for all messages.
> - **Param:** ``Destination`` **Type:** ``string`` The nickname of the remote machine you are sending the message to.
> - **Param:** ``Message`` **Type:** ``string`` The string of text to send to the remote machine.
>
>***This function currently prints all returns to console.***

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
