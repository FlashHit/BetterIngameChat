import './utils/WebUI';

import { createRoot } from 'react-dom/client';

import App from './App.tsx';

const onResize = () => {
    const designHeight = 1080;
    const actualHeight = window.innerHeight;
    const scaleFactor = actualHeight / designHeight;

    // Let's say 1rem = 1px at 1080p. So we scale this.
    document.documentElement.style.fontSize = `${scaleFactor}px`;
};

onResize();
window.addEventListener('resize', onResize);

try {
    createRoot(document.getElementById('root')!).render(<App />);
} catch (err) {
    console.error(err);
}
