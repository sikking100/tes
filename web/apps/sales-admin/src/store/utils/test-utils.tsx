/* eslint-disable import/export */
import { Provider } from 'ui'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { cleanup, render } from '@testing-library/react'
import { BrowserRouter } from 'react-router-dom'
import { ChakraProvider } from '@chakra-ui/provider'

const queryClient = new QueryClient({
    defaultOptions: {
        queries: {
            retry: false,
        },
    },
})

const AllTheProviders: React.FC<{ children: React.ReactNode }> = ({
    children,
}) => {
    return (
        <QueryClientProvider client={queryClient}>
            <ChakraProvider>
                <BrowserRouter>{children}</BrowserRouter>
            </ChakraProvider>
        </QueryClientProvider>
    )
}

const customRender = (ui: React.ReactElement, options = {}) =>
    render(ui, { wrapper: AllTheProviders, ...options })

export * from '@testing-library/react'
export { default as userEvent } from '@testing-library/user-event'
// override render export
export { customRender as render }
