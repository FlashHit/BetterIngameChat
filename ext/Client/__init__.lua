local EnableTyping = require 'enableTyping'
local IncomingMessages = require 'incomingMessages'
local OutgoingMessages = require 'outgoingMessages'

class 'BetterIngameChat'

function BetterIngameChat:__init()
	-- Subscribe to events.
	self.m_ExtensionLoadedEvent = Events:Subscribe('Extension:Loaded', self, self.OnExtensionLoaded)

	-- Initialize the other components.
	self.m_EnableTyping = EnableTyping()
	self.m_IncomingMessages = IncomingMessages()
	self.m_OutgoingMessages = OutgoingMessages()
end

function BetterIngameChat:OnExtensionLoaded()
	WebUI:Init()
end

g_BetterIngameChat = BetterIngameChat()
