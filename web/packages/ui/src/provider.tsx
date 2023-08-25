import React from 'react'
import { ChakraProvider } from '@chakra-ui/provider'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { ToastContainer } from 'react-toastify'
import { Slide } from 'react-toastify'
import theme from './theme'
import 'react-toastify/dist/ReactToastify.css'

interface IProviderProps {
    children: React.ReactNode
}

const queryClient = new QueryClient({
    defaultOptions: {
        queries: {},
    },
})

const Provider: React.FC<IProviderProps> = (props) => {
    return (
        <QueryClientProvider client={queryClient}>
            <ChakraProvider theme={theme}>
                <>{props.children}</>
                <ToastContainer
                    closeOnClick
                    position="bottom-right"
                    autoClose={1500}
                    rtl={false}
                    className="toaster-container"
                    transition={Slide}
                    closeButton={false}
                    hideProgressBar={true}
                    newestOnTop={false}
                />
            </ChakraProvider>
        </QueryClientProvider>
    )
}

export default Provider
