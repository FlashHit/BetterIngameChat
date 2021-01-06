class 'IncomingMessages'

local m_StoreManager = require "StoreManager"

function IncomingMessages:__init()
	self.m_CreateChatMessage = Hooks:Install('UI:CreateChatMessage',999, self, self.OnUICreateChatMessage)
end

function IncomingMessages:OnUICreateChatMessage(p_Hook, p_Message, p_Channel, p_PlayerId, p_RecipientMask, p_SenderIsDead)
	if p_Message == nil then
		return
	end

	--print("OnCreateChatMessage")

	-- Get the player sending the message, and our local player.
	local s_OtherPlayer = PlayerManager:GetPlayerById(p_PlayerId)
	local s_LocalPlayer = PlayerManager:GetLocalPlayer()
	local s_Target
	local s_Table = {}


	if p_Channel == ChatChannelType.CctAdmin then
		-- This is a workaround because many RCON tools prepend
		-- "Admin: " to admin messages.
		local s_String = p_Message:gsub("^Admin: ", '')

		s_Table = {author = "Admin", content = s_String, target = "admin"}
		--print('OnMessage, '.. json.encode(s_Table))
		m_StoreManager:Dispatch("OnMessage", s_Table)

		goto continue
	end


	-- Players not found; cancel.
	if s_OtherPlayer == nil and s_LocalPlayer == nil then
		goto continue
	end

	-- Player is a spectator.
	if s_OtherPlayer.teamId == 0 then
		s_Target = "spectator"

	-- Player sends a direct message
	-- example: "DirectMessage voteban flash: Hello Mate!"
	-- so s_Target = "voteban flash" and p_Message = "Hello Mate!"
	elseif p_Message:gsub(":.*$", ""):match("DirectMessage") then
		p_Message = p_Message:match("^[a-z]+:(.*)$")
		s_Target = p_Message:gsub(":.*$", ""):gsub("DirectMessage ", "")
	
	-- Player is on a different team; display enemy message.
	elseif (s_LocalPlayer.teamId == 0 and s_OtherPlayer.teamId == 2) or (s_LocalPlayer.teamId ~= 0 and s_OtherPlayer.teamId ~= s_LocalPlayer.teamId) then
		s_Target = "enemy"

	-- Player is in the same team.
	-- Display global message.
	elseif p_Channel == ChatChannelType.CctSayAll and s_LocalPlayer.teamId ~= 0 then
		s_Target = "all"

	-- Player sends a squad leader message
	elseif p_Channel == ChatChannelType.CctSquadLeader or (ChatChannelType.CctTeam and p_Message:gsub(":.*$", "") == "SquadLeaderMessage") then
		p_Message = p_Message:match("^[a-z]+:(.*)$")
		s_Target = "squadLeader"
		
	-- Display team message.
	elseif p_Channel == ChatChannelType.CctTeam or s_LocalPlayer.teamId == 0 then
		s_Target = "team"

	-- Display squad message.
	elseif p_Channel == ChatChannelType.CctSquad then
		s_Target = "squad"
	else
		goto continue
	end

	s_Table = {author = s_OtherPlayer.name, content = p_Message, target = s_Target}
	--print('OnMessage, '.. json.encode(s_Table))
	m_StoreManager:Dispatch("OnMessage", s_Table)

	::continue::

	-- A new chat message is being created; 
	-- prevent the game from rendering it.
	p_Hook:Return()
end

return IncomingMessages