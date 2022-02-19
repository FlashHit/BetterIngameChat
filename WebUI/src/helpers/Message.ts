import { MessageTarget } from "./MessageTarget";

interface Message {
    message: string;
    senderName: string;
    messageTarget: MessageTarget;
    playerRelation: string;
    targetName: string|null;
}

export default Message;
