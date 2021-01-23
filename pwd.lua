local hostCh
local selfCh
local timeout = 5
local protocol = "pwd"
local MODES = {}
MODES.LOCKDOWN = "lockdown"
MODES.NORMAL = "normal"
local mode = MODES.NORMAL

function initModem ()
  rednet.open("top")
  rednet.host("pwd", protocol)
  rednet.broadcast("init", protocol);
  local senderID, message = rednet.receive(protocol, timeout)
  if message == nil then
    return error("Failed init")
  else
    hostCh = senderID
    selfCh = message
  end
end

function readPassword ()
  term.clear()
  term.setCursorPos(1,1)
  print("Enter password:")
  return read("*")
end

function createPayload (pwd)
  local pwdMessage = {}
  pwdMessage.type = "password_attempt"
  pwdMessage.payload = pwd
  return pwdMessage
end

function attemptPassword (pwd)
  rednet.send(hostCh, createPayload(pwd), protocol)
  local senderID, message = rednet.receive(protocol, timeout)
  if message == nil then
    print("Host is down, sorry!")
    sleep(5)
  elseif message == "attempts_exhausted" then
    print("You're a bad boy!")
    mode = MODES.LOCKDOWN
  elseif message == "wrong_password" then
    print("Wrong!")
    sleep(1)
  else then
    print("Welcome!")
    sleep(1)
  end
end

initModem()

while true do
  if mode == MODE.NORMAL
    local pwd = readPassword()
    attemptPassword(pwd)
  else
    local senderID, message = rednet.receive(protocol, timeout)
    if message == "clear_tries" then
      mode = MODES.NORMAL
    end
  end
end