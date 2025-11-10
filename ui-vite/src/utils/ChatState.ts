export enum ChatState {
    Popup,
    Always,
    Hidden,
}

export const ChatStateString: { [key: string]: string } = {
    [ChatState.Popup]: 'Popup',
    [ChatState.Always]: 'Always',
    [ChatState.Hidden]: 'Hidden',
};
