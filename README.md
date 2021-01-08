# BetterIngameChat

- Background color represents the channel:
  - Admin = Purple? -- maybe just the normal channel? like if its a admin message for all then black, if its for a player then pink(?) -- but [ADMIN] always purple? -- the question is how I see if the admin message was sent to me or to all?
  -- OR we make it always purple but the [ADMIN] color tells us if its a direct or all message
  - All = (red/)orange (enemy) or black (teammate/squadmate) -- orange is cool but maybe black would be enough, dunno.
  - Team = blue
  - Squad = green
  - SquadLeader = blue (too) -- maybe a darker blue idk
  - (DirectMessage) Player = Pink? or darker red
- Player color represents the relation:
  - LocalPlayer = white
  - SquadMate = green
  - TeamMate = blue
  - Enemy = (red/)orange
  - Admin(Player) = purple or normal color? -- format is: `[ADMIN] playername: message` -- so I think it could be also just the normal player relation color 
  (playername needs to be implemented as well then, but should be easy. will be just on the server like `Netevents.... player, (message) message = player.name .. ": " .. message`
  - Directmessage? = pink as well? or darker red -- because what if an enemy sends a direct message? then its orange on pink or on darker red 
  
  
- Direct Messages (Shift + Chatkey)
- Normal Messages will highlight @Player in it
- @player and direct messages will open a dropdown to choose the targetPlayer faster
- Emoji support :kek:
- Spectator support (in vanilla the chat is off, I would let them write, even in all channel)
- Squad Leader support (disabled by default)
- Server chat config: 
  - Enable/ disable channels
- Admin support (requires gameAdmin to track if they are admin) and then we make (Ctrl + Chatkey) -- or maybe just Shift + SayAllChat -- thinking about sending private messages as admin
      -- maybe (Ctrl + chatKey) => Admin message to all channel
      -- but (Ctrl + squadChatKey) => Admin direct player message
