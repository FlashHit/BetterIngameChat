class 'EnableTyping'

require "ChatConfig"

function EnableTyping:__init()
	self.m_IsAdmin = false
	-- Install our hooks.
	self.m_InputConceptEventHook = Hooks:Install('UI:InputConceptEvent', 999, self, self.OnInputConceptEvent)
	
	-- NetEvents for admins
	self.m_AddAdminPlayerEvent = NetEvents:Subscribe('AddAdminPlayer', self, self.OnAddAdminPlayer)
	self.m_RemoveAdminPlayerEvent = NetEvents:Subscribe('RemoveAdminPlayer', self, self.OnRemoveAdminPlayer)
	
end

function EnableTyping:OnInputConceptEvent(p_Hook, p_EventType, p_Action)
	-- If this is a chat-related input concept event then filter it
	-- to prevent the game from showing the default chat dialog.
	
	if InputManager:IsKeyDown(InputDeviceKeys.IDK_LeftShift) and p_EventType == UIInputActionEventType.UIInputActionEventType_Pressed and (p_Action == UIInputAction.UIInputAction_SayAllChat or p_Action == UIInputAction.UIInputAction_TeamChat or p_Action == UIInputAction.UIInputAction_SquadChat) then
		WebUI:ExecuteJS(string.format("OnFocus('%s')", ChatConfig.shiftCombination))
		p_Hook:Pass(UIInputAction.UIInputAction_None, p_EventType)
	end
	
	if self.m_IsAdmin == true then
		if InputManager:IsKeyDown(InputDeviceKeys.IDK_LeftCtrl) and p_EventType == UIInputActionEventType.UIInputActionEventType_Pressed and (p_Action == UIInputAction.UIInputAction_SquadChat) then
			WebUI:ExecuteJS(string.format("OnFocus('%s')", ChatConfig.ctrlSquadCombination))
			p_Hook:Pass(UIInputAction.UIInputAction_None, p_EventType)
		end
		
		if InputManager:IsKeyDown(InputDeviceKeys.IDK_LeftCtrl) and p_EventType == UIInputActionEventType.UIInputActionEventType_Pressed and (p_Action == UIInputAction.UIInputAction_SayAllChat or p_Action == UIInputAction.UIInputAction_TeamChat) then
			WebUI:ExecuteJS(string.format("OnFocus('%s')", ChatConfig.ctrlCombination))
			p_Hook:Pass(UIInputAction.UIInputAction_None, p_EventType)
		end
	end

	if p_Action == UIInputAction.UIInputAction_SayAllChat and p_EventType == UIInputActionEventType.UIInputActionEventType_Pressed then
		WebUI:ExecuteJS(string.format("OnFocus('%s')", ChatConfig.sayAllChat))
		p_Hook:Pass(UIInputAction.UIInputAction_None, p_EventType)
		return
	end

	if p_Action == UIInputAction.UIInputAction_TeamChat and p_EventType == UIInputActionEventType.UIInputActionEventType_Pressed then
		WebUI:ExecuteJS(string.format("OnFocus('%s')", ChatConfig.teamChat))
		p_Hook:Pass(UIInputAction.UIInputAction_None, p_EventType)
		return
	end

	if p_Action == UIInputAction.UIInputAction_SquadChat and p_EventType == UIInputActionEventType.UIInputActionEventType_Pressed then
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

function EnableTyping:OnAddAdminPlayer()
	self.m_IsAdmin = true
end

function EnableTyping:OnRemoveAdminPlayer()
	self.m_IsAdmin = false
end

return EnableTyping
