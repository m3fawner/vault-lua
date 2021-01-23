# vault-lua

This project is to manage a door/piston system for a minecraft
vault using ComputerCraft.

## General

The system is comprised of three never-ending programs.

_The Host_ - The host is the bus for all network messages, controlling the door and piston state.

_The client_ - The client is the internal computer intended to
be used to modify the settings & mode of the host.

_pwd_ - This is the password script, which is responsible only
for taking in input & messaging it to the host.

## host.lua

`host.lua` represents the "brain" of the operation. It can be
configured by updating the PISTON_DIRECTION and DOOR_DIRECTION to
meet your needs.

Generally, it is responsible for three things: setting the piston,
setting the door, and informing the other clients.

It contains three local state variables:

- Mode - The current mode it is in. Currently supports normal and lockdown modes.
- Password - The password that is correct. It can be updated via the client. It is set to `newPassword` on initialization.
- Attempts - the number of failed attempts at the password, to be used to determine `mode`

It responds to the following rednet messages:

- clear_tries - Clears the attempt count, notifies the password computer it is clear to allow input
- init - Responds with the sender's ID (an ack, more or less)

Additionally, it responds to "redux-like" messages which have a type and payload

- set_mode (payload: the mode) - Sets the operation mode (normal/lockdown)
- set_door (payload: bool) - Sets the door to open or closed based on the bool payload
- password_attempt (payload: string) - Responds to an attempt at entering the password. After 3 failed attempts, it goes into lockdown mode. The payloads of wrong_password or correct_password are sent to the sender according to the password match result. At 3 failed attempts, that payload is attempts_exhausted
- password_update (payload: string) - Updates the in memory password

## client.lua

The `client.lua` file is a simplistic menu system that gives several functions to the user. It can set the door, set the mode, change the password, and reset password attempts. It is to be within the vault, as it is not password protected.

## pwd.lua

`pwd.lua` should be run on the external facing computer. The piston portion of the logic is to control a piston to block the computer from further access in lockdown. It is extremely naive to the broader system, only sending the user input to the host & responding to the payloads sent by the host that are pertinent (attempts_exhausted, wrong_password, clear_tries, password_attempt)
