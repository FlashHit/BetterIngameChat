import React, { useEffect, useState } from "react";
import { ChatState, ChatStateString } from "../helpers/ChatState";

interface Props {
    chatState: ChatState;
}

const BombPlantInfoBox: React.FC<Props> = ({ chatState }) => {
    const [firstRun, setFirstRun] = useState<boolean>(true);
    const [visible, setVisible] = useState<boolean>(false);

    useEffect(() => {
        if (firstRun) {
            setFirstRun(false);
            return;
        }
        setVisible(true);
        const interval = setTimeout(() => {
            setVisible(false);
        }, 1000);
        return () => {
            clearTimeout(interval);
        }
    }, [chatState]);

    return (
        <>
            {visible &&
                <div id="VuChatStatePopup">
                    Chat mode: {ChatStateString[chatState]??''}
                </div>
            }
        </>
    );
};

export default BombPlantInfoBox;
