import './App.scss';

import clsx from 'clsx';
import React, { useMemo, useRef, useState } from 'react';

import ChatForm from './components/ChatForm';
import ChatStatePopup from './components/ChatStatePopup';
import { ChatState } from './utils/ChatState';
import { MessageTarget, MessageTargetString } from './utils/MessageTarget';

let debugMode: boolean = false;
if (window.location.protocol !== 'webui:') {
    debugMode = true;
}

const App: React.FC = () => {
    const [messages, setMessage] = useState<IMessage[]>([]);
    const [popupActive, setPopupActive] = useState<boolean>(false);
    const [chatState, setChatState] = useState<ChatState>(ChatState.Popup);
    const [isTypingActive, setIsTypingActive] = useState<boolean>(false);
    const [chatTarget, setChatTarget] = useState<MessageTarget>(MessageTarget.CctSayAll);
    const [playerList, setPlayerList] = useState<string[]>([]);
    const [playerName, setPlayerName] = useState<string | null>(null);
    const chatWindowRef = useRef<HTMLDivElement>(null);
    const popupTimerRef = useRef<number>(null);

    const setRandomMessages = () => {
        addMessage({
            message: 'tasd',
            senderName: 'username',
            messageTarget: MessageTarget.CctEnemy,
            playerRelation: 'none',
            targetName: null,
        });
    };

    const addMessage = (message: IMessage) => {
        setMessage((prev: IMessage[]) => {
            if (prev.length >= 50) {
                return [...prev.slice(1, 50), message];
            } else {
                return [...prev, message];
            }
        });

        if (popupTimerRef.current) clearInterval(popupTimerRef.current);
        setPopupActive(true);
        popupTimerRef.current = setInterval(() => {
            setPopupActive(false);
        }, 5000);

        if (!isTypingActive) {
            scrollToBottom();
        }
    };

    const scrollToBottom = () => {
        if (!chatWindowRef.current) return;
        chatWindowRef.current.scrollTop = chatWindowRef.current.scrollHeight;
    };

    /* Window */
    window.OnFocus = (p_Target: MessageTarget) => {
        // window.WebUI.Call('BringToFront');
        window.WebUI.Call('EnableKeyboard');
        window.WebUI.Call('EnableMouse');

        setChatTarget(p_Target);
        setIsTypingActive(true);
    };

    window.OnMessage = (p_DataJson: any) => {
        addMessage({
            message: p_DataJson.content.toString(),
            senderName: p_DataJson.author.toString(),
            messageTarget: p_DataJson.target,
            playerRelation: p_DataJson.playerRelation,
            targetName: p_DataJson.targetName,
        });
    };

    window.OnChangeType = () => {
        if (chatState === ChatState.Popup) {
            setChatState(ChatState.Always);
        } else if (chatState === ChatState.Always) {
            setChatState(ChatState.Hidden);
        } else if (chatState === ChatState.Hidden) {
            setChatState(ChatState.Popup);
        }
    };

    window.OnUpdatePlayerName = (p_Name: any) => {
        setPlayerName(`@${p_Name.toString()}`);
    };

    window.OnUpdatePlayerList = (m_CollectedPlayers: any) => {
        const collectedPlayers: string[] = Object.values(m_CollectedPlayers);
        if (collectedPlayers.length > 0) {
            setPlayerList(collectedPlayers);
        } else {
            setPlayerList([]);
        }
    };

    window.OnClearChat = () => {
        setMessage([]);
    };

    window.OnCloseChat = () => {
        setCloseChat();
    };

    const setCloseChat = () => {
        window.WebUI.Call('DispatchEventLocal', 'WebUI:SetCursor');

        setIsTypingActive(false);
    };

    const chatIsVisibleMemo = useMemo(() => {
        if (isTypingActive) return true;
        if (chatState === ChatState.Always) return true;
        if (chatState === ChatState.Popup && popupActive) return true;
        return false;
    }, [isTypingActive, chatState, popupActive]);

    return (
        <>
            {debugMode ? (
                <style
                    dangerouslySetInnerHTML={{
                        __html: `
                    body {
                        background: #333;
                    }

                    #debug {
                        display: block !important;
                        opacity: 0.1;
                    }
                `,
                    }}
                />
            ) : null}
            <div id="debug">
                <button onClick={() => setRandomMessages()}>Random messages</button>
                <button onClick={() => window.OnFocus(MessageTarget.CctSayAll)}>isTypingActive</button>
                <button onClick={() => window.OnChangeType()}>OnChangeType</button>
                <button onClick={() => window.OnClearChat()}>OnClearChat</button>
                <button onClick={() => window.OnCloseChat()}>OnCloseChat</button>
            </div>

            <div
                id="VuChat"
                className={clsx({
                    showChat: chatIsVisibleMemo,
                    isTypingActive: isTypingActive || chatState === ChatState.Always,
                })}
            >
                <div className="chatWindow" ref={chatWindowRef}>
                    {messages.map((message: IMessage, index: number) => (
                        // @ts-expect-error We expect an error here because of cohinline.
                        <p className={getChatItemClasses(message)} key={index} cohinline>
                            <span className="chatMessageTarget">[{getChatItemTarget(message)}]</span>
                            <span className="chatSender">{message.senderName}:</span>
                            <span className="chatMessage">
                                {/*playerName !== null ? (
                                        <Highlight search={playerName}>{message.message}</Highlight>
                                    ) : (
                                        message.message
                                    )*/}
                                {message.message}
                            </span>
                        </p>
                    ))}
                </div>
            </div>
            <ChatForm
                target={chatTarget}
                isTypingActive={isTypingActive}
                doneTypeing={() => setCloseChat()}
                playerList={playerList}
            />
            <ChatStatePopup state={chatState} />
        </>
    );
};

export default App;

declare global {
    interface Window {
        OnFocus: (p_Target: MessageTarget) => void;
        OnMessage: (p_DataJson: any) => void;
        OnChangeType: () => void;
        OnUpdatePlayerList: (m_CollectedPlayers: any) => void;
        OnUpdatePlayerName: (p_Name: string) => void;
        OnClearChat: () => void;
        OnCloseChat: () => void;
    }
}

const getChatItemClasses = (message: IMessage) => {
    const classNames: string[] = ['chatItem'];
    classNames.push(`chatType${MessageTargetString[message.messageTarget]}`);
    switch (message.playerRelation) {
        case 'localPlayer':
            classNames.push('chatLocalPlayer');
            break;
        case 'squadMate':
            classNames.push('chatSquadmate');
            break;
        case 'spectator':
            classNames.push('chatSpectator');
            break;
    }
    return clsx(classNames);
};

const getChatItemTarget = (message: IMessage) => {
    if (message.messageTarget === MessageTarget.CctPlayer || message.messageTarget === MessageTarget.CctAdminPlayer) {
        if (message.playerRelation === 'localPlayer') {
            if (message.targetName !== undefined) {
                return `TO ${message.targetName}`;
            } else {
                return 'FROM';
            }
        } else {
            return 'FROM';
        }
    } else if (message.messageTarget === MessageTarget.CctEnemy) {
        return 'ALL';
    } else {
        return MessageTargetString[message.messageTarget];
    }
};
