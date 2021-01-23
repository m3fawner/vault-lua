local selfCh
local timeout = 5
local protocol = "pwd"

local MODES = {}
MODES.NORMAL = "normal"
MODES.LOCKDOWN = "lockdown"
local mode = MODES.NORMAL

local PISTON_DIRECTION = "left"
local PISTON_STATES = {}
PISTON_STATES[MODES.NORMAL] = false
PISTON_STATES[MODES.LOCKDOWN] = true

local DOOR_DIRECTION = "back"
local DOOR_STATES = {}
DOOR_STATES[MODES.NORMAL] = true
DOOR_STATES[MODES.LOCKDOWN] = false

function setPiston (value)
  rs.setOutput(PISTON_DIRECTION, value)
end

function setDoor (value)
  rs.setOutput(DOOR_DIRECTION, value)
end

function updateMode (newMode)
 setPiston(PISTON_STATES[newMode])
 setDoor(DOOR_STATES[newMode])
 mode = newMode
end

local password
function updatePassword (newPass)
  password = newPass
end

local attempts = 0
function performPasswordCheck (attempt)
  local result = "wrong_password"
  if attempt == password then
    attempts = 0
    setDoor(true)
    result = "correct_password"
    if mode == MODES.LOCKDOWN then
      print("In lockdown, self-closing door in 5")
      sleep(5)
      setDoor(false)
    end
  else
    attempts = attempts + 1
    if attempts >= 3 then
      result = "attempts_exhausted"
      updateMode(MODES.LOCKDOWN)
    end
  end
  return result
end

function messageHandler ()
  local senderID, message = rednet.receive(protocol, timeout)
  if message == nil then
    return
  end
  if type(message) == string then
    print(message)
    if message == "init" then
      rednet.send(senderID, senderID, protocol)
    elseif message.type == "clear_tries" then
      attempts = 0
      setPiston(false)
      rednet.broadcast("clear_tries", protocol)
    end
  else
    print(message.type)

    -- Mode actions
    if message.type == "set_mode" then
      updateMode(message.payload)

    -- Door actions
    elseif message.type == "set_door" then
      setDoor(message.payload)

    -- Password actions
    elseif message.type == "password_attempt" then
      result = performPasswordCheck(message.payload)
      rednet.send(senderID, result, protocol)
    elseif message.type == "password_update" then
      updatePassword(message.payload)
    end
  end
end


function initModem ()
  rednet.open("top")
  rednet.host("host", protocol)
  print("Initialized host.")
end

initModem()
updateMode(MODES.NORMAL)
updatePassword("newPassword")

while true do
  messageHandler()
end