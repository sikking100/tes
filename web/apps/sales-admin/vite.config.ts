import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import path from 'path'
import { viteStaticCopy } from 'vite-plugin-static-copy'


export default defineConfig(({ mode }) => ({
    define: {
        'process.env.NODE_ENV': JSON.stringify(mode),
    },
    plugins: [
        react(),
        viteStaticCopy({
            targets: [
                {
                    src: path.resolve(__dirname, './public'), // 1️⃣
                    dest: './dist', // 2️⃣
                },
            ],
        }),
    ],
    server: {
        port: 3003,
    },
    resolve: {
        alias: [{ find: '~', replacement: path.resolve(__dirname, 'src') }],
    },
    test: {
        environment: 'jsdom',
        globals: true,
        setupFiles: 'testSetup/msw.ts',
    },
    build: {
        target: 'esnext',
    },
}));
