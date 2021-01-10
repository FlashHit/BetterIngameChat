# BetterIngameChat

Based on the [Advanced-Chat](https://github.com/EmulatorNexus/Advanced-Chat/) mod BetterIngameChat is a replacement for the default chat window.

### Features
- Responsive layout
- Color represented channels (heavily inspired by the Reality Mod's chat UI design)
  - All = Orange (enemy), Blue (teammate), Lime (squadmate)
  - Team = Blue
  - Squad = Lime
  - SquadLeader = Teal
  - DirectMessage = Purple
  - Admin = Pink
  
- Direct Messages
  - Press **Shift + Chatkey**, search for the player's name, Tab or select his name from the dropdown, type in the message and send.
- Name higlighter
  - If you send a message that contains `@PlayerNameHere`, thier name will get highlighted for them.
- Spectator chat support
- End of round chat support
- Squad Leader channel support - **Shift + SquadChatkey**
- Admin support (requires gameAdmin to track if they are admin)
  - **Ctrl + AllChatkey**  - Admin message to all channel
  - **Ctrl + TeamChatkey**  - Anonymus admin message to all channel
  - **Ctrl + SquadChatkey**  - Admin direct mesage to a player
- **(SOON™)** Emoji support like: `:pog:`

### Devs
- [FlashHit](https://github.com/FlashHit)
- [KVN](https://github.com/kaloczikvn)
- 
Big thanks to the original crators of the Advanced-Chat mod:
- [FoolHen](https://github.com/FoolHen)
- [OrfeasZ](https://github.com/OrfeasZ)
- [Powback](https://github.com/Powback)

*We wanted to create a Pull Request first but Vue is really not my cup of tea and I don't want to overwrite the whole ui of your project just beacuse I work in React, but we can still contribute to that project if you'd like it!*
