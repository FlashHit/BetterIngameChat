import { MessageTarget } from "./MessageTarget";

interface Message {
    message: string;
    senderName: string;
    messageTarget: MessageTarget;
    playerRelation: string,
}

export default Message;
