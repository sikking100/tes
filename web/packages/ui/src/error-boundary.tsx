import { Box, Button, Spinner } from '@chakra-ui/react'
import { QueryErrorResetBoundary } from '@tanstack/react-query'
import React from 'react'
import { ErrorBoundary, FallbackProps } from 'react-error-boundary'

export const ErrorBoundarys: React.FC<{ children: React.ReactNode }> = ({
    children,
}) => {
    return (
        <QueryErrorResetBoundary>
            {({ reset }) => (
                <ErrorBoundary onReset={reset} FallbackComponent={ErrorView}>
                    <React.Suspense fallback={<Spinner bg={'red.200'} />}>
                        {children}
                    </React.Suspense>
                </ErrorBoundary>
            )}
        </QueryErrorResetBoundary>
    )
}

const ErrorView = ({ error, resetErrorBoundary }: FallbackProps) => {
    return (
        <Box>
            <Box>{error.message}</Box>
            <Button onClick={resetErrorBoundary}>Coba Lagi</Button>
        </Box>
    )
}
