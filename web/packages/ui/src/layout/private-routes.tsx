import React from 'react'
import { Navigate, Outlet } from 'react-router-dom'
import { store, useAuth } from 'hooks'
import { Text, Box } from '@chakra-ui/layout'
import { Spinner } from '@chakra-ui/spinner'

const Loading = () => (
    <Box
        pos={'absolute'}
        left={'50%'}
        top={'50%'}
        transform={'translate(-50%, 100%)'}
    >
        <Spinner
            thickness="4px"
            speed="1s"
            emptyColor="gray.200"
            color="red.100"
            size="xl"
        />
    </Box>
)

export interface PrivateRouteProps {
    components: React.ReactNode
}

export const PrivateRoute: React.FC<PrivateRouteProps> = (
    props: PrivateRouteProps
) => {
    const { error, loading, user } = useAuth()
    const setUser = store.useStore((i) => i.setAdmin)

    React.useEffect(() => {
        if (user) setUser()
    }, [user])

    if (error) return <Text>Error: {error.message}</Text>
    if (loading) return <Loading />

    return <>{user ? <>{props.components}</> : <Navigate to="/login" />}</>
}
