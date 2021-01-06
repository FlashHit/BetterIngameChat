import { MessageTarget } from "./MessageTarget";

interface Message {
    message: string;
    senderName: string;
    messageTarget: MessageTarget;
}

export default Message;
