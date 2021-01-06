class 'EnableTyping'

require "ChatConfig"

function EnableTyping:__init()
	-- Install our hooks.
	self.m_InputConceptEventHook = Hooks:Install('UI:InputConceptEvent', 999, self, self.OnInputConceptEvent)
end

function EnableTyping:OnInputConceptEvent(p_Hook, p_EventType, p_Action)
	-- If this is a chat-related input concept event then filter it
	-- to prevent the game from showing the default chat dialog.
	--print("OnInputConceptEvent")
	
	if InputManager:IsKeyDown(InputDeviceKeys.IDK_LeftShift) and p_EventType == UIInputActionEventType.UIInputActionEventType_Pressed and (p_Action == UIInputAction.UIInputAction_SayAllChat or p_Action == UIInputAction.UIInputAction_TeamChat or p_Action == UIInputAction.UIInputAction_SquadChat) then
		--m_StoreManager:Dispatch("EnableTyping", m_Config.shiftCombination)
		WebUI:ExecuteJS(string.format("OnFocus('%s')", ChatConfig.shiftCombination))
		p_Hook:Pass(UIInputAction.UIInputAction_None, p_EventType)
	end

	if p_Action == UIInputAction.UIInputAction_SayAllChat and p_EventType == UIInputActionEventType.UIInputActionEventType_Pressed then
		--m_StoreManager:Dispatch("EnableTyping", m_Config.sayAllChat)
		WebUI:ExecuteJS(string.format("OnFocus('%s')", ChatConfig.sayAllChat))
		p_Hook:Pass(UIInputAction.UIInputAction_None, p_EventType)
		return
	end

	if p_Action == UIInputAction.UIInputAction_TeamChat and p_EventType == UIInputActionEventType.UIInputActionEventType_Pressed then
		--m_StoreManager:Dispatch("EnableTyping", m_Config.teamChat)
		WebUI:ExecuteJS(string.format("OnFocus('%s')", ChatConfig.teamChat))
		p_Hook:Pass(UIInputAction.UIInputAction_None, p_EventType)
		return
	end

	if p_Action == UIInputAction.UIInputAction_SquadChat and p_EventType == UIInputActionEventType.UIInputActionEventType_Pressed then
		--m_StoreManager:Dispatch("EnableTyping", m_Config.squadChat)
		WebUI:ExecuteJS(string.format("OnFocus('%s')", ChatConfig.squadChat))
		p_Hook:Pass(UIInputAction.UIInputAction_None, p_EventType)
		return
	end

	-- TODO: Fixme
	--[[if p_Action == UIInputAction.UIInputAction_ToggleChat and p_EventType == UIInputActionEventType.UIInputActionEventType_Pressed then
		m_StoreManager:Dispatch("ToggleDisplayMode")
		p_Hook:Pass(UIInputAction.UIInputAction_None, p_EventType)
		return
	end]]

	-- Otherwise, let the game handle it as it normally does.
end

return EnableTyping
