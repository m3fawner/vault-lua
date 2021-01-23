local hostCh
local selfCh
local timeout = 5
local protocol = "pwd"

function initModem ()
  rednet.open("top")
  rednet.host("client", protocol)
  rednet.broadcast("init", protocol);
  local senderID, message = rednet.receive(protocol, timeout)
  if message == nil then
    return error("Failed init")
  else
    hostCh = senderID
    selfCh = message
  end
end

function messageHost (payload, mType)
  local message
  if mType == nil then
    message = payload
  else
    message = {}
    message.type = mType
    message.payload = payload
  end
  rednet.send(hostCh, message, protocol)
end

function setMode (mode)
  messageHost(mode, "set_mode")
end

function printMenu (title, ...)
  term.clear()
  term.setCursorPos(1,1)
  print(title)
  local args = table.pack(...)
  for i=1,args.n do
      print(i .. ". " .. args[i])
  end
  option = read()
  return tonumber(option)
end

local menus = {}
function topMenu ()
  option = printMenu(
    "Welcome! Here's the menu",
    "Set door",
    "Set mode",
    "Change password",
    "Reset attempts"
  )
  menus[option]()
end
menus[0] = topMenu


function setDoor ()
  option = printMenu(
    "Door control",
    "Open door",
    "Close door"
  )
  messageHost(option == 1, "set_door")
end
menus[1] = setDoor

function setModeSelection ()
 option = printMenu("Select mode", "Normal", "Lockdown")
 if option == 1 then
  setMode("normal")
 elseif option == 2 then
  setMode("lockdown")
 end
end
menus[2] = setModeSelection

function changePassword ()
  term.clear()
  term.setCursorPos(1,1)
  print("Enter new password:")
  newPass = read("*")
  print("Confirm password:")
  confirm = read("*")
  if newPass == confirmPass then
    messageHost(newPass, "password_update")
  else
    print("Passwords did not match")
    sleep(2)
    changePassword()
  end
end
menus[3] = changePassword

function resetAttempts ()
  messageHost("clear_tries")
end
menus[4] = resetAttempts

initModem()
sleep(1)

while true do
  topMenu()
end