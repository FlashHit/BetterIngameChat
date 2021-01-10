export enum MessageTarget {
    CctSayAll = 'all',
    CctTeam = 'team',
    CctSquad = 'squad',
    CctSquadLeader = 'squadleader',
    CctAdmin = 'admin',
    CctPlayer = 'player',
    CctEnemy = 'enemy',
    CctSpectator = 'spectator',
    CctAdminAnonym = "adminAnonym",
	CctAdminPlayer = "adminPlayer"
}

export var MessageTargetString = {
    [MessageTarget.CctSayAll]: 'All',
    [MessageTarget.CctTeam]: 'Team',
    [MessageTarget.CctSquad]: 'Squad',
    [MessageTarget.CctSquadLeader]: 'Leaders',
    [MessageTarget.CctAdmin]: 'Admin',
    [MessageTarget.CctPlayer]: 'Player',
    [MessageTarget.CctEnemy]: 'Enemy',
    [MessageTarget.CctSpectator]: 'Spectator',
    [MessageTarget.CctAdminAnonym]: 'Admin',
    [MessageTarget.CctAdminPlayer]: 'Admin',
}

export default MessageTarget;
