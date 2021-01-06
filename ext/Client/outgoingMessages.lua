class 'OutgoingMessages'

function OutgoingMessages:__init()
	self.m_SendChatMessage = Events:Subscribe('WebUI:OutgoingChatMessage', self, self.OnWebUIOutgoingChatMessage)
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

	--print("message: "..p_Message..", target: "..s_Target)

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
	
	if p_Target == 'squadleader' then
		NetEvents:Send('Message:ToSquadLeaders', {p_Message})
		return
	end
	
	if p_Target == 'player' and p_TargetName ~= nil then
		NetEvents:Send('Message:ToPlayer', {p_Message, p_TargetName})
		return
	end

	return
end

return OutgoingMessages
