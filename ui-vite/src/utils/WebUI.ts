window.WebUI = window.WebUI || {
    Call: () => {},
};

declare global {
    interface Window {
        WebUI: {
            Call: (value: string, ...props: any) => void;
        };
    }
}
