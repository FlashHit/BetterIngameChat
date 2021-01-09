import React, { useEffect, useRef, useState } from "react";

import { MessageTarget, MessageTargetString } from "../helpers/MessageTarget";

import { Typeahead } from '@gforge/react-typeahead-ts';

import './ChatForm.scss';

interface Props {
    target: MessageTarget;
    isTypingActive: boolean;
    doneTypeing: () => void;
    playerList: string[];
}

const Title: React.FC<Props> = ({ target, isTypingActive, doneTypeing, playerList }) => {
    const [inputMessage, setInputMessage] = useState<string>('');
    const [targetName, setTargetName] = useState<string|null>(null);
    const targetRef = useRef(targetName);
    targetRef.current = targetName;

    const onChange = (event: any) => {
        setInputMessage(event.target.value);
    }

    const onKeyDown = (event: any) => {
        switch (event.key) {
            case 'Enter':
                onSubmit(event);
                break;
            case 'Escape':
                setTargetName(null);
                resetInputMessage();
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

    const onBlur = (typeHead: boolean = false) => {
        setTimeout(() => {
            resetInputMessage();

            if (typeHead && targetRef.current !== null) {
                return;
            }

            setTargetName(null);
            resetKeyboardAndMouse();
        }, 100);
    }

    const onSubmit = (event: any) => {
        event.preventDefault();

        if (target === MessageTarget.CctPlayer && targetName === null) {
            return;
        }

        if (inputMessage.length > 0 && navigator.userAgent.includes('VeniceUnleashed')) {
            WebUI.Call('DispatchEventLocal', 'WebUI:OutgoingChatMessage', JSON.stringify({ message: inputMessage, target: target, targetName: targetName }));
        }

        setTargetName(null);

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
        if (targetName !== null) {
            setInputMessage('');
        }

        if (isTypingActive && inputEl && inputEl.current) {
            inputEl.current.focus();
        }
    }, [isTypingActive, targetName]);

    const inputProps = {
        maxLength: 127,
        type: "text",
        spellCheck: false,
    };

    return (
        <>
            {isTypingActive &&
                <div id="chatForm" className={MessageTargetString[target]??''}>
                    <label>
                        {targetName !== null
                        ?
                            <>
                                {targetName}
                            </>
                        :
                            <>
                                {MessageTargetString[target]??''}
                            </>
                        }
                    </label>
                    {(target === MessageTarget.CctPlayer && targetName === null)
                    ?
                        <Typeahead 
                            options={playerList} 
                            maxVisible={3} 
                            value={inputMessage} 
                            onKeyDown={onKeyDown} 
                            onBlur={() => onBlur(true)} 
                            onChange={onChange}
                            innerRef={inputEl}
                            inputProps={inputProps}
                            onOptionSelected={(value: any) => {
                                setTargetName(value);
                            }}
                            placeholder="Search for a player..."
                        />
                    :
                        <input 
                            type="text" 
                            maxLength={127}
                            value={inputMessage} 
                            onKeyDown={onKeyDown} 
                            onBlur={() => onBlur(false)} 
                            onChange={onChange}
                            spellCheck={false}
                            ref={inputEl}
                        />
                    }
                </div>
            }
        </>
    );
};

export default Title;
