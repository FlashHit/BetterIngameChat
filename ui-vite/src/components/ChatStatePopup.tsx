import './ChatStatePopup.scss';

import React, { useEffect, useRef, useState } from 'react';

import { ChatState, ChatStateString } from '../utils/ChatState';

interface Props {
    state: ChatState;
}

const ChatStatePopup: React.FC<Props> = ({ state }) => {
    const firstRenderRef = useRef<boolean>(true);
    const [visible, setVisible] = useState<boolean>(false);

    useEffect(() => {
        if (firstRenderRef.current) {
            firstRenderRef.current = false;
            return;
        }

        setVisible(true);

        const interval = setTimeout(() => {
            setVisible(false);
        }, 1000);

        return () => {
            clearTimeout(interval);
        };
    }, [state]);

    if (!visible) return null;

    return (
        // @ts-expect-error We expect an error here because of cohinline.
        <p id="VuChatStatePopup" cohinline>
            Chat mode: {ChatStateString[state] || ''}
        </p>
    );
};

export default ChatStatePopup;
