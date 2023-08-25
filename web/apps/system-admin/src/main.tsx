import React from 'react'
import ReactDOM from 'react-dom/client'
import { Provider } from 'ui'
import App from './App'

ReactDOM.createRoot(document.getElementById('root') as HTMLElement).render(
    <Provider>
        <App />
    </Provider>
)
