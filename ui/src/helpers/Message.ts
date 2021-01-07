import { MessageTarget } from "./MessageTarget";

interface Message {
    message: string;
    senderName: string;
    messageTarget: MessageTarget;
    squadMate: boolean,
}

export default Message;
