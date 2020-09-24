const getFlags = () => ({
    screen: { width: window.innerWidth, height: window.innerHeight },
    theme:
        window.matchMedia &&
        window.matchMedia('(prefers-color-scheme: dark)').matches
            ? 'dark'
            : 'light',
});

const App = {
    init() {
        window.Elm.Main.init({
            flags: getFlags(),
            // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
            node: document.getElementById('elm')!,
        });
    },
};

App.init();
