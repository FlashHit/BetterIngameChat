import React, { useEffect, useRef, useState } from "react";

import { loremIpsum, username } from 'react-lorem-ipsum';
import ChatForm from "./components/ChatForm";

import Message from "./helpers/Message";
import { MessageTarget, MessageTargetString } from "./helpers/MessageTarget";
import Player from "./helpers/Player";
import ChatState from "./helpers/ChatState";

import 'line-awesome/dist/line-awesome/css/line-awesome.min.css';
import './App.scss';
import ChatStatePopup from "./components/ChatStatePopup";

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
            message: loremIpsum({ p: 1, avgSentencesPerParagraph: 2, startWithLoremIpsum: false }).toString(),
            senderName: username(),
            messageTarget: MessageTarget.CctTeam,
            squadMate: false,
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

        if (message.squadMate) {
            classes += " chatSquadmate";
        }
        

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
        if (!isTypingActive) {
            if (chatState === ChatState.Popup) {
                if (interval !== null) {
                    clearTimeout(interval);
                }
        
                setShowChat(true);
                
                interval = setTimeout(() => {
                    setShowChat(false);
                }, 5000);

                return () => {
                    clearTimeout(interval);
                }
            } else if(chatState === ChatState.Always) {
                setShowChat(true);
            } else {
                setShowChat(false);
            }
        } else {
            clearTimeout(interval);
        }
    }, [messages, chatState, isTypingActive]);

    /* Window */
    window.OnFocus = (p_Target: MessageTarget) => {
        if (navigator.userAgent.includes('VeniceUnleashed')) {
            WebUI.Call('BringToFront');
            WebUI.Call('EnableKeyboard');
            WebUI.Call('EnableMouse');
        }

        setShowChat(true);
        setChatTarget(p_Target);
        setIsTypingActive(true);
    }

    window.OnMessage = (p_DataJson: any) => {
        addMessage({
            message: p_DataJson.content.toString(),
            senderName: p_DataJson.author.toString(),
            messageTarget: p_DataJson.target,
            squadMate: p_DataJson.isSquadMate,
        });
    }

    window.OnChangeType = () => {
        if (chatState === ChatState.Popup) {
            setChatState(ChatState.Always);
        } else if(chatState === ChatState.Always) {
            setChatState(ChatState.Hidden);
        } else if(chatState === ChatState.Hidden) {
            setChatState(ChatState.Popup);
        }
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
                <button onClick={() =>  window.OnChangeType()}>OnChangeType</button>
            </div>

            <div id="VuChat" className={(showChat ? "showChat" : "hideChat") + ((isTypingActive || chatState === ChatState.Always) ? " isTypingActive": "")}>
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
            <ChatStatePopup chatState={chatState} />
        </>
    );
};

export default App;

declare global {
    interface Window {
        OnFocus: (p_Target: MessageTarget) => void;
        OnMessage: (p_DataJson: any) => void;
        OnChangeType: () => void;
    }
}
