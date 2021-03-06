class 'OutgoingMessages'

function OutgoingMessages:__init()
	self.m_SendChatMessage = Events:Subscribe('WebUI:OutgoingChatMessage', self, self.OnWebUIOutgoingChatMessage)
	self.m_SetCursor = Events:Subscribe('WebUI:SetCursor', self, self.OnWebUISetCursor)
	
	self.m_EngineUpdateEvent = Events:Subscribe('Engine:Update', self, self.OnEngineUpdate)
	self.m_EnableTimer = false
	self.m_Timer = 0.035
	self.m_CumulatedTime = 0
end

function OutgoingMessages:OnWebUIOutgoingChatMessage(p_JsonData)
	local s_DecodedData = json.decode(p_JsonData)

	-- Load params from the decoded JSON.
	local p_Target = s_DecodedData.target
	local p_Message = s_DecodedData.message
	local p_TargetName = s_DecodedData.targetName

	-- Trim the message.
	local s_From = p_Message:match"^%s*()"
 	p_Message = s_From > #p_Message and "" or p_Message:match(".*%S", s_From)

	-- Ignore if the message is empty.
	if p_Message:len() == 0 then
		return
	end

	-- Get the local player.
	local s_LocalPlayer = PlayerManager:GetLocalPlayer()

	-- We can't send a message if we don't have an active player.
	if s_LocalPlayer == nil then
		return
	end

	-- Dispatch message based on the specified target.
	if p_Target == 'all' then
		ChatManager:SendMessage(p_Message)
		return
	end

	if p_Target == 'team' then
		ChatManager:SendMessage(p_Message, s_LocalPlayer.teamId)
		return
	end

	if p_Target == 'squad' then
		ChatManager:SendMessage(p_Message, s_LocalPlayer.teamId, s_LocalPlayer.squadId)
		return
	end
	
	if p_Target == 'squadLeader' then
		NetEvents:Send('Message:ToSquadLeaders', {p_Message})
		return
	end
	
	if p_Target == 'player' and p_TargetName ~= nil then
		NetEvents:Send('Message:ToPlayer', {p_Message, p_TargetName})
		
		s_Table = {author = s_LocalPlayer.name, content = p_Message, target = "player", playerRelation = "localPlayer", targetName = p_TargetName}	
		WebUI:ExecuteJS(string.format("OnMessage(%s)", json.encode(s_Table)))
		return
	end
	
	if p_Target == 'admin'then
		NetEvents:Send('AdminMessage:ToAll', {p_Message, false})
		return
	end
	
	if p_Target == 'adminAnonym' then
		NetEvents:Send('AdminMessage:ToAll', {p_Message, true})
		return
	end
	
	if p_Target == 'adminPlayer' and p_TargetName ~= nil then
		NetEvents:Send('AdminMessage:ToPlayer', {p_Message, p_TargetName})
		
		s_Table = {author = s_LocalPlayer.name, content = p_Message, target = "adminPlayer", playerRelation = "localPlayer", targetName = p_TargetName}	
		WebUI:ExecuteJS(string.format("OnMessage(%s)", json.encode(s_Table)))
		return
	end

	return
end

function OutgoingMessages:OnWebUISetCursor()
	local s_WindowSize = ClientUtils:GetWindowSize()
	InputManager:SetCursorPosition(s_WindowSize.x / 2, s_WindowSize.y / 2)
	WebUI:ResetKeyboard()
	self.m_EnableTimer = true
end

function OutgoingMessages:OnEngineUpdate(deltaTime)
	if not self.m_EnableTimer then
		return
	end
	self.m_CumulatedTime = self.m_CumulatedTime + deltaTime
	if self.m_CumulatedTime > self.m_Timer then
		self.m_CumulatedTime = 0
		self.m_EnableTimer = false
		WebUI:ResetMouse()
	end
end

return OutgoingMessages
