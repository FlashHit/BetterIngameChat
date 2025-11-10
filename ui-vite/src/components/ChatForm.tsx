import './ChatForm.scss';

import React, { useEffect, useRef, useState } from 'react';

import { MessageTarget, MessageTargetString } from '../utils/MessageTarget';

interface Props {
    target: MessageTarget;
    isTypingActive: boolean;
    doneTypeing: () => void;
    playerList: string[];
}

const ChatForm: React.FC<Props> = ({ target, isTypingActive, doneTypeing }) => {
    const [inputMessage, setInputMessage] = useState<string>('');
    const [targetName, setTargetName] = useState<string | null>(null);
    const inputRef = useRef<HTMLInputElement>(null);
    const targetRef = useRef(targetName);
    targetRef.current = targetName;

    const onChange = (event: any) => {
        setInputMessage(event.target.value);
    };

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
    };

    const onBlur = (typeHead: boolean = false) => {
        setTimeout(() => {
            resetInputMessage();

            if (typeHead && targetRef.current !== null) {
                return;
            }

            setTargetName(null);
            resetKeyboardAndMouse();
        }, 100);
    };

    const onSubmit = (event: any) => {
        event.preventDefault();

        if ((target === MessageTarget.CctPlayer || target === MessageTarget.CctAdminPlayer) && targetName === null) {
            return;
        }

        if (inputMessage.length > 0) {
            window.WebUI.Call(
                'DispatchEventLocal',
                'WebUI:OutgoingChatMessage',
                JSON.stringify({ message: inputMessage, target: target, targetName: targetName })
            );
        }

        setTargetName(null);

        resetInputMessage();
        resetKeyboardAndMouse();
    };

    const resetInputMessage = () => {
        setInputMessage('');
    };

    const resetKeyboardAndMouse = () => {
        doneTypeing();
    };

    useEffect(() => {
        if (targetName !== null) {
            setInputMessage('');
        }

        if (isTypingActive && inputRef && inputRef.current) {
            inputRef.current.focus();
        }
    }, [isTypingActive, targetName]);

    if (!isTypingActive) return null;

    return (
        <div id="chatForm" className={MessageTargetString[target] ?? ''}>
            <label>{targetName !== null ? <>{targetName}</> : <>{MessageTargetString[target] ?? ''}</>}</label>
            {/*(target === MessageTarget.CctPlayer || target === MessageTarget.CctAdminPlayer) && targetName === null ? (
                <Typeahead
                    options={playerList}
                    maxVisible={3}
                    value={inputMessage}
                    onKeyDown={onKeyDown}
                    onBlur={() => onBlur(true)}
                    onChange={onChange}
                    innerRef={inputRef}
                    inputProps={{
                        maxLength: 127,
                        type: 'text',
                        spellCheck: false,
                    }}
                    onOptionSelected={(value: any) => {
                        setTargetName(value);
                        setInputMessage('');
                    }}
                    placeholder="Search for a player..."
                />
            ) : (
                <div>
                    <input
                        type="text"
                        maxLength={127}
                        value={inputMessage}
                        onKeyDown={onKeyDown}
                        onBlur={() => onBlur(false)}
                        onChange={onChange}
                        spellCheck={false}
                        ref={inputRef}
                    />
                </div>
            )*/}
            <input
                type="text"
                maxLength={127}
                value={inputMessage}
                onKeyDown={onKeyDown}
                onBlur={() => onBlur(false)}
                onChange={onChange}
                spellCheck={false}
                ref={inputRef}
            />
        </div>
    );
};

export default ChatForm;
