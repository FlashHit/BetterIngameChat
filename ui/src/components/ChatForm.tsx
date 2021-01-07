import React, { useEffect, useRef, useState } from "react";

import { MessageTarget, MessageTargetString } from "../helpers/MessageTarget";

import './ChatForm.scss';

interface Props {
    target: MessageTarget;
    isTypingActive: boolean;
    doneTypeing: () => void;
}

const Title: React.FC<Props> = ({ target, isTypingActive, doneTypeing }) => {
    const [inputMessage, setInputMessage] = useState<string>('');

    const onChange = (event: any) => {
        setInputMessage(event.target.value);
    }

    const onKeyDown = (event: any) => {
        switch (event.key) {
            case 'Enter':
                onSubmit(event);
                break;
            case 'Escape':
                resetKeyboardAndMouse();
                break;
            case 'ArrowUp':
                event.preventDefault();
                break;
            case 'ArrowDown':
                event.preventDefault();
                break;
        }
    }

    const onBlur = () => {
        resetInputMessage();
        resetKeyboardAndMouse();
    }

    const onSubmit = (event: any) => {
        event.preventDefault();

        if (inputMessage.length > 0 && navigator.userAgent.includes('VeniceUnleashed')) {
            WebUI.Call('DispatchEventLocal', 'WebUI:OutgoingChatMessage', JSON.stringify({ message: inputMessage, target: target, targetName: null }));
        }

        resetInputMessage();
        resetKeyboardAndMouse();
    }

    const resetInputMessage = () => {
        setInputMessage('');
    }

    const resetKeyboardAndMouse = () => {
        if (navigator.userAgent.includes('VeniceUnleashed')) {
            WebUI.Call('ResetKeyboard');
            WebUI.Call('SendToBack');
            WebUI.Call('ResetMouse');
        }

        doneTypeing();
    }

    const inputEl = useRef(null);
    useEffect(() => {
        if (isTypingActive && inputEl && inputEl.current) {
            inputEl.current.focus();
        }
    }, [isTypingActive])

    return (
        <>
            {isTypingActive &&
                <div id="chatForm" className={MessageTargetString[target]??''}>
                    <label>
                        {MessageTargetString[target]??''}
                    </label>
                    <input 
                        type="text" 
                        maxLength={127}
                        value={inputMessage} 
                        onKeyDown={onKeyDown} 
                        onBlur={onBlur} 
                        onChange={onChange}
                        ref={inputEl}
                    />
                </div>
            }
        </>
    );
};

export default Title;
