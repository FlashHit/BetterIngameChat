interface IMessage {
    message: string;
    senderName: string;
    messageTarget: MessageTarget;
    playerRelation: string;
    targetName: string | null;
}

interface IPlayer {
    name: string;
    teamId: number;
    squadId: number;
}
