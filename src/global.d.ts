export {};

// eslint-disable-next-line @typescript-eslint/no-empty-interface
interface Ports {}

declare global {
    interface Window {
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        Elm: {
            Main: {
                init: (args: {
                    flags: { [key: string]: unknown };
                    node: HTMLElement;
                }) => { ports: Ports };
            };
        };
    }
}
