export enum ChatState {
    Popup,
    Always,
    Hidden,
}

export var ChatStateString = {
    [ChatState.Popup]: 'Popup',
    [ChatState.Always]: 'Always',
    [ChatState.Hidden]: 'Hidden',
}

export default ChatState;
