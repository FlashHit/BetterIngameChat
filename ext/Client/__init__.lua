---@class ClientBetterIngameChat
ClientBetterIngameChat = class 'ClientBetterIngameChat'

---@type EnableTyping
local m_EnableTyping = require 'EnableTyping'
---@type IncomingMessages
local m_IncomingMessages = require 'IncomingMessages'
---@type OutgoingMessages
local m_OutgoingMessages = require 'OutgoingMessages'
---@type CollectedPlayers
local m_CollectedPlayers = require 'CollectedPlayers'

function ClientBetterIngameChat:__init()
	-- Subscribe events
	Events:Subscribe('Extension:Loaded', self, self.OnExtensionLoaded)
	Events:Subscribe('Engine:Update', self, self.OnEngineUpdate)
	Events:Subscribe('Level:Destroy', self, self.OnLevelDestroy)
	Events:Subscribe('Player:Connected', self, self.OnPlayerConnected)
	Events:Subscribe('Player:Deleted', self, self.OnPlayerDeleted)

	-- Install hooks
	Hooks:Install('UI:InputConceptEvent', 999, self, self.OnUIInputConceptEvent)
	Hooks:Install('UI:CreateChatMessage', 999, self, self.OnUICreateChatMessage)
end

function ClientBetterIngameChat:OnExtensionLoaded()
	WebUI:Init()
end

---@param p_DeltaTime number
---@param p_SimulationDeltaTime number
function ClientBetterIngameChat:OnEngineUpdate(p_DeltaTime, p_SimulationDeltaTime)
	m_OutgoingMessages:OnEngineUpdate(p_DeltaTime, p_SimulationDeltaTime)
end

function ClientBetterIngameChat:OnLevelDestroy()
	WebUI:ExecuteJS("OnClearChat()")
end

---@param p_Player Player
function ClientBetterIngameChat:OnPlayerConnected(p_Player)
	m_CollectedPlayers:OnPlayerConnected(p_Player)
end

---@param p_Player Player
function ClientBetterIngameChat:OnPlayerDeleted(p_Player)
	m_CollectedPlayers:OnPlayerDeleted(p_Player)
end

---@param p_HookCtx HookContext
---@param p_EventType UIInputActionEventType|integer
---@param p_Action UIInputAction|integer
function ClientBetterIngameChat:OnUIInputConceptEvent(p_HookCtx, p_EventType, p_Action)
	m_EnableTyping:OnUIInputConceptEvent(p_HookCtx, p_EventType, p_Action)
end

---@param p_HookCtx HookContext
---@param p_Message string
---@param p_ChannelId ChatChannelType|integer
---@param p_PlayerId integer
---@param p_RecipientMask integer
---@param p_IsSenderDead boolean
function ClientBetterIngameChat:OnUICreateChatMessage(p_HookCtx, p_Message, p_ChannelId, p_PlayerId, p_RecipientMask, p_IsSenderDead)
	m_IncomingMessages:OnUICreateChatMessage(p_HookCtx, p_Message, p_ChannelId, p_PlayerId, p_RecipientMask, p_IsSenderDead)
end

ClientBetterIngameChat()
