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
	
	if InputManager:IsKeyDown(InputDeviceKeys.IDK_LeftShift) and p_EventType == UIInputActionEventType.UIInputActionEventType_Pressed and (p_Action == UIInputAction.UIInputAction_TeamChat or p_Action == UIInputAction.UIInputAction_SquadChat) and ChatConfig.playerChat then
		WebUI:ExecuteJS(string.format("OnFocus('%s')", "player"))
		p_Hook:Pass(UIInputAction.UIInputAction_None, p_EventType)
		return
	end
	
	if InputManager:IsKeyDown(InputDeviceKeys.IDK_LeftShift) and p_EventType == UIInputActionEventType.UIInputActionEventType_Pressed and p_Action == UIInputAction.UIInputAction_SayAllChat and ChatConfig.playerChat then
		WebUI:ExecuteJS(string.format("OnFocus('%s')", "squadLeader"))
		p_Hook:Pass(UIInputAction.UIInputAction_None, p_EventType)
		return
	end
	
	if self.m_IsAdmin == true then
		if InputManager:IsKeyDown(InputDeviceKeys.IDK_LeftCtrl) and p_EventType == UIInputActionEventType.UIInputActionEventType_Pressed and p_Action == UIInputAction.UIInputAction_SquadChat and ChatConfig.adminPlayerChat == true then
			WebUI:ExecuteJS(string.format("OnFocus('%s')", "adminPlayer"))
			p_Hook:Pass(UIInputAction.UIInputAction_None, p_EventType)
			return
		end
		
		if InputManager:IsKeyDown(InputDeviceKeys.IDK_LeftCtrl) and p_EventType == UIInputActionEventType.UIInputActionEventType_Pressed and p_Action == UIInputAction.UIInputAction_TeamChat and ChatConfig.anonymAdminSayAllChat == true then
			WebUI:ExecuteJS(string.format("OnFocus('%s')", "adminAnonym"))
			p_Hook:Pass(UIInputAction.UIInputAction_None, p_EventType)
			return
		end
		
		if InputManager:IsKeyDown(InputDeviceKeys.IDK_LeftCtrl) and p_EventType == UIInputActionEventType.UIInputActionEventType_Pressed and p_Action == UIInputAction.UIInputAction_SayAllChat and ChatConfig.adminSayAllChat == true then
			WebUI:ExecuteJS(string.format("OnFocus('%s')", "admin"))
			p_Hook:Pass(UIInputAction.UIInputAction_None, p_EventType)
			return
		end
	end

	if p_Action == UIInputAction.UIInputAction_SayAllChat and p_EventType == UIInputActionEventType.UIInputActionEventType_Pressed and ChatConfig.sayAllChat == true then
		WebUI:ExecuteJS(string.format("OnFocus('%s')", "all"))
		p_Hook:Pass(UIInputAction.UIInputAction_None, p_EventType)
		return
	end

	if p_Action == UIInputAction.UIInputAction_TeamChat and p_EventType == UIInputActionEventType.UIInputActionEventType_Pressed then
		if SpectatorManager:GetSpectating() then
			if ChatConfig.sayAllChat == true then
				WebUI:ExecuteJS(string.format("OnFocus('%s')", "all"))
			end
		elseif ChatConfig.teamChat == true then
			WebUI:ExecuteJS(string.format("OnFocus('%s')", "team"))
		end
		
		p_Hook:Pass(UIInputAction.UIInputAction_None, p_EventType)
		return
	end

	if p_Action == UIInputAction.UIInputAction_SquadChat and p_EventType == UIInputActionEventType.UIInputActionEventType_Pressed then
		if SpectatorManager:GetSpectating() then
			if ChatConfig.sayAllChat == true then
				WebUI:ExecuteJS(string.format("OnFocus('%s')", "all"))
			end
		elseif ChatConfig.squadChat == true then
			WebUI:ExecuteJS(string.format("OnFocus('%s')", "squad"))
		end
		
		p_Hook:Pass(UIInputAction.UIInputAction_None, p_EventType)
		return
	end

	if p_Action == UIInputAction.UIInputAction_ToggleChat and p_EventType == UIInputActionEventType.UIInputActionEventType_Pressed then
		WebUI:ExecuteJS("OnChangeType()")
		p_Hook:Pass(UIInputAction.UIInputAction_None, p_EventType)
		return
	end
	
	-- Otherwise, let the game handle it as it normally does.
end

function EnableTyping:OnAddAdminPlayer()
	self.m_IsAdmin = true
end

function EnableTyping:OnRemoveAdminPlayer()
	self.m_IsAdmin = false
end

return EnableTyping
