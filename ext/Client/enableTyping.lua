class 'EnableTyping'

local m_StoreManager = require "StoreManager"
local m_Config = require "config"

function EnableTyping:__init()
	self.m_CursorMode = false

	-- Install our hooks.
	self.m_EnableCursorModeHook = Hooks:Install('UI:EnableCursorMode', 999, self, self.OnEnableCursorMode)
	self.m_InputConceptEventHook = Hooks:Install('UI:InputConceptEvent', 999, self, self.OnInputConceptEvent)

	-- Subscribe to events.
	self.m_DisableMouseEvent = Events:Subscribe('WebUI:DisableMouse', self, self.OnDisableMouse)
	self.m_EnableMouseEvent = Events:Subscribe('WebUI:EnableMouse', self, self.OnEnableMouse)
end

function EnableTyping:OnInputConceptEvent(p_Hook, p_EventType, p_Action)
	-- If this is a chat-related input concept event then filter it
	-- to prevent the game from showing the default chat dialog.
	--print("OnInputConceptEvent")
	
	if InputManager:IsKeyDown(InputDeviceKeys.IDK_LeftShift) and p_EventType == UIInputActionEventType.UIInputActionEventType_Pressed and (p_Action == UIInputAction.UIInputAction_SayAllChat or p_Action == UIInputAction.UIInputAction_TeamChat or p_Action == UIInputAction.UIInputAction_SquadChat) then
		m_StoreManager:Dispatch("EnableTyping", m_Config.shiftCombination)
		p_Hook:Pass(UIInputAction.UIInputAction_None, p_EventType)
	end

	if p_Action == UIInputAction.UIInputAction_SayAllChat and p_EventType == UIInputActionEventType.UIInputActionEventType_Pressed then
		m_StoreManager:Dispatch("EnableTyping", m_Config.sayAllChat)
		p_Hook:Pass(UIInputAction.UIInputAction_None, p_EventType)
		return
	end

	if p_Action == UIInputAction.UIInputAction_TeamChat and p_EventType == UIInputActionEventType.UIInputActionEventType_Pressed then
		m_StoreManager:Dispatch("EnableTyping", m_Config.teamChat)
		p_Hook:Pass(UIInputAction.UIInputAction_None, p_EventType)
		return
	end

	if p_Action == UIInputAction.UIInputAction_SquadChat and p_EventType == UIInputActionEventType.UIInputActionEventType_Pressed then
		m_StoreManager:Dispatch("EnableTyping", m_Config.squadChat)
		p_Hook:Pass(UIInputAction.UIInputAction_None, p_EventType)
		return
	end

	if p_Action == UIInputAction.UIInputAction_ToggleChat and p_EventType == UIInputActionEventType.UIInputActionEventType_Pressed then
		m_StoreManager:Dispatch("ToggleDisplayMode")
		p_Hook:Pass(UIInputAction.UIInputAction_None, p_EventType)
		return
	end

	-- Otherwise, let the game handle it as it normally does.
end

-- Region Mouse Cursor
-- We store the current mouse cursor (enables/disabled) 
-- and then if the WebUI requests it we just check if we have to enable it or is it already enabled.
function EnableTyping:OnEnableCursorMode(p_Hook, p_Enable, p_Cursor)
	self.m_CursorMode = p_Enable
end

function EnableTyping:OnDisableMouse()
	if self.m_CursorMode then
		return
	end
	WebUI:DisableMouse()
end

function EnableTyping:OnEnableMouse()
	if self.m_CursorMode then
		return
	end
	WebUI:EnableMouse()
end

return EnableTyping