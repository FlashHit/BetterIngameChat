import React, { useEffect, useRef, useState } from "react";

import { loremIpsum, username } from 'react-lorem-ipsum';
import ChatForm from "./components/ChatForm";

import Message from "./helpers/Message";
import { MessageTarget, MessageTargetString } from "./helpers/MessageTarget";
import Player from "./helpers/Player";
import ChatState from "./helpers/ChatState";

import 'line-awesome/dist/line-awesome/css/line-awesome.min.css';
import './App.scss';

const App: React.FC = () => {
    /*
    * Debug
    */
    let debugMode: boolean = false;
    if (!navigator.userAgent.includes('VeniceUnleashed')) {
        if (window.location.ancestorOrigins === undefined || window.location.ancestorOrigins[0] !== 'webui://main') {
            debugMode = true;
        }
    }

    const [messages, setMessage] = useState<Message[]>([]);
    const [showChat, setShowChat] = useState<boolean>(false);
    const [chatState, setChatState] = useState<ChatState>(ChatState.Popup);
    const [isTypingActive, setIsTypingActive] = useState<boolean>(false);
    const [chatTarget, setChatTarget] = useState<MessageTarget>(MessageTarget.CctSayAll);

    const setRandomMessages = () => {
        addMessage({
            message: "🥝 " + loremIpsum({ p: 1, avgSentencesPerParagraph: 2, startWithLoremIpsum: false }).toString(),
            senderName: username(),
            messageTarget: MessageTarget.CctSayAll,
        });
    }

    const addMessage = (message: Message) => {
        setMessage((prevState: any) => [
            ...prevState,
            message,
        ]);
    }

    const getChatItemClasses = (message: Message) => {
        var classes = "chatItem";

        classes += " chatType" + MessageTargetString[message.messageTarget];

        return classes;
    }

    const messageEl = useRef(null);
    useEffect(() => {
        if (messageEl && messageEl.current && !isTypingActive) {
            scrollToBottom(messageEl.current);
        }
    }, [messages]);

    window.addEventListener('resize', () => {
        if (messageEl && messageEl.current) {
            scrollToBottom(messageEl.current);
        }
    });

    const scrollToBottom = (current: any) => {
        current.scroll({ top: messageEl.current.scrollHeight, behavior: 'auto' });
    };
    
    var interval: any = null;
    useEffect(() => {
        if (chatState === ChatState.Popup) {
            if (interval !== null) {
                clearInterval(interval);
            }
    
            if (messages.length > 0) {
                setShowChat(true);
                
                interval = setInterval(() => {
                    setShowChat(false);
                }, 5000);
            }
    
            return () => {
                clearInterval(interval);
            }
        } else if(chatState === ChatState.Always) {
            setShowChat(true);
        } else {
            setShowChat(false);
        }
    }, [messages]);

    /* Window */
    window.OnFocus = (p_Target: MessageTarget) => {
        clearInterval(interval);
        setShowChat(true);

        setChatTarget(p_Target);
        setIsTypingActive(true);

        WebUI.Call('BringToFront');
        WebUI.Call('EnableKeyboard');
        WebUI.Call('EnableMouse');
    }

    window.OnMessage = (p_DataJson: any) => {
        console.log(p_DataJson);
        addMessage({
            message: p_DataJson.content.toString(),
            senderName: p_DataJson.author.toString(),
            messageTarget: p_DataJson.target,
        });
    }

    return (
        <>
            {debugMode &&
                <style dangerouslySetInnerHTML={{
                    __html: `
                    body {
                        background: #333;
                    }

                    #debug {
                        display: block !important;
                        opacity: 0.1;
                    }
                `}} />
            }
            <div id="debug">
                <button onClick={() => setRandomMessages()}>Random messages</button>
                <button onClick={() =>  window.OnFocus(MessageTarget.CctAdmin)}>isTypingActive</button>
            </div>

            <div id="VuChat" className={(showChat ? "showChat" : "hideChat") + (isTypingActive ? " isTypingActive": "")}>
                <div className="chatWindow" ref={messageEl}>
                    <div className="chatWindowInner">
                        {messages.map((message: Message, index: number) => (
                            <div className={getChatItemClasses(message)} key={index}>
                                <span className="chatMessageTarget">[{MessageTargetString[message.messageTarget]}]</span>
                                <span className="chatSender">{message.senderName}:</span>
                                <span className="chatMessage">{message.message}</span>
                            </div>
                        ))}
                    </div>
                </div>
                <ChatForm target={chatTarget} isTypingActive={isTypingActive} doneTypeing={() => setIsTypingActive(false)} />
            </div>
        </>
    );
};

export default App;

declare global {
    interface Window {
        OnFocus: (p_Target: MessageTarget) => void;
        OnMessage: (p_DataJson: any) => void;
    }
}
