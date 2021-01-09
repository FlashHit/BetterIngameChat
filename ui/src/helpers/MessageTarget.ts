export enum MessageTarget {
    CctSayAll = 'all',
    CctTeam = 'team',
    CctSquad = 'squad',
    CctSquadLeader = 'squadleader',
    CctAdmin = 'admin',
    CctPlayer = 'player',
    CctEnemy = 'enemy',
    CctSpectator = 'spectator',
}

export var MessageTargetString = {
    [MessageTarget.CctSayAll]: 'All',
    [MessageTarget.CctTeam]: 'Team',
    [MessageTarget.CctSquad]: 'Squad',
    [MessageTarget.CctSquadLeader]: 'Leader',
    [MessageTarget.CctAdmin]: 'Admin',
    [MessageTarget.CctPlayer]: 'Player',
    [MessageTarget.CctEnemy]: 'Enemy',
    [MessageTarget.CctSpectator]: 'Spectator',
}

export default MessageTarget;
