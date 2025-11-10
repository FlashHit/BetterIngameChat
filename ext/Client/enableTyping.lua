---@class EnableTyping
EnableTyping = class 'EnableTyping'

--get the config
local m_Config = require "Config"

--make the InputManager local
local InputManager = InputManager

function EnableTyping:__init()
	self.m_IsAdmin = false

	-- NetEvents
	NetEvents:Subscribe('AddAdminPlayer', self, self.OnAddAdminPlayer)
	NetEvents:Subscribe('RemoveAdminPlayer', self, self.OnRemoveAdminPlayer)
end

---@param p_HookCtx HookContext
---@param p_EventType UIInputActionEventType|integer
---@param p_Action UIInputAction|integer
function EnableTyping:OnUIInputConceptEvent(p_HookCtx, p_EventType, p_Action)
	-- filter for pressing key (skip releasing keys)
	if p_EventType ~= UIInputActionEventType.UIInputActionEventType_Pressed then
		return
	end

	-- To Player chat
	--[[ TODO: Re-enable Player chat when UI is ready
	if (p_Action == UIInputAction.UIInputAction_TeamChat or p_Action == UIInputAction.UIInputAction_SquadChat)
	and m_Config.playerChat
	and InputManager:IsKeyDown(InputDeviceKeys.IDK_LeftShift) then
		WebUI:ExecuteJS(string.format("OnFocus('%s')", "player"))
		p_HookCtx:Pass(UIInputAction.UIInputAction_None, p_EventType)
		return
	end
	]]

	-- SquadLeader chat
	if p_Action == UIInputAction.UIInputAction_SayAllChat
	and m_Config.playerChat
	and not SpectatorManager:GetSpectating()
	and InputManager:IsKeyDown(InputDeviceKeys.IDK_LeftShift) then
		local s_LocalPlayer = PlayerManager:GetLocalPlayer()

		if s_LocalPlayer ~= nil	and s_LocalPlayer.isSquadLeader then
			WebUI:ExecuteJS(string.format("OnFocus('%s')", "squadLeader"))
			p_HookCtx:Pass(UIInputAction.UIInputAction_None, p_EventType)
			return
		end
	end

	-- Admin chat
	if self.m_IsAdmin and InputManager:IsKeyDown(InputDeviceKeys.IDK_LeftCtrl) then
		-- admin to player chat
		if p_Action == UIInputAction.UIInputAction_SquadChat
		and m_Config.adminPlayerChat then
			WebUI:ExecuteJS(string.format("OnFocus('%s')", "adminPlayer"))
			p_HookCtx:Pass(UIInputAction.UIInputAction_None, p_EventType)
			return
		end

		-- anonym admin all chat
		if p_Action == UIInputAction.UIInputAction_TeamChat
		and m_Config.anonymAdminSayAllChat then
			WebUI:ExecuteJS(string.format("OnFocus('%s')", "adminAnonym"))
			p_HookCtx:Pass(UIInputAction.UIInputAction_None, p_EventType)
			return
		end

		-- admin all chat
		if p_Action == UIInputAction.UIInputAction_SayAllChat
		and m_Config.adminSayAllChat then
			WebUI:ExecuteJS(string.format("OnFocus('%s')", "admin"))
			p_HookCtx:Pass(UIInputAction.UIInputAction_None, p_EventType)
			return
		end
	end

	-- all chat
	if p_Action == UIInputAction.UIInputAction_SayAllChat and m_Config.sayAllChat then
		WebUI:ExecuteJS(string.format("OnFocus('%s')", "all"))
		p_HookCtx:Pass(UIInputAction.UIInputAction_None, p_EventType)
		return
	end

	-- team chat
	if p_Action == UIInputAction.UIInputAction_TeamChat then
		if SpectatorManager:GetSpectating() then
			-- spectators have only all chat
			if m_Config.sayAllChat then
				WebUI:ExecuteJS(string.format("OnFocus('%s')", "all"))
			end
		elseif m_Config.teamChat then
			WebUI:ExecuteJS(string.format("OnFocus('%s')", "team"))
		end

		p_HookCtx:Pass(UIInputAction.UIInputAction_None, p_EventType)
		return
	end

	-- squad chat
	if p_Action == UIInputAction.UIInputAction_SquadChat then
		if SpectatorManager:GetSpectating() then
			-- spectators have only all chat
			if m_Config.sayAllChat then
				WebUI:ExecuteJS(string.format("OnFocus('%s')", "all"))
			end
		elseif m_Config.squadChat then
			WebUI:ExecuteJS(string.format("OnFocus('%s')", "squad"))
		end

		p_HookCtx:Pass(UIInputAction.UIInputAction_None, p_EventType)
		return
	end

	-- toggle chat (hidden, pop-up, always)
	if p_Action == UIInputAction.UIInputAction_ToggleChat then
		WebUI:ExecuteJS("OnChangeType()")
		p_HookCtx:Pass(UIInputAction.UIInputAction_None, p_EventType)
		return
	end

	-- Otherwise, let the game handle it as it normally does.
end

-- local player is admin
function EnableTyping:OnAddAdminPlayer()
	self.m_IsAdmin = true
end

-- local player is no admin anymore
function EnableTyping:OnRemoveAdminPlayer()
	self.m_IsAdmin = false
end

return EnableTyping()
