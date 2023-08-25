import '../theme/global.css'
import React from 'react'
import { Box } from '@chakra-ui/layout'

import Navbar from './navbar'
import Sidebar from './sidebar'
import { appName, SidebarProps } from '../types'
import { Network } from '../network'
import { ErrorBoundarys } from '../error-boundary'
import { SetFcm } from 'hooks'

interface AuthenticatedLayout extends SidebarProps {
    children: React.ReactNode
    appName: appName
}

const Root: React.FC<AuthenticatedLayout> = (props: AuthenticatedLayout) => {
    React.useEffect(() => {
        const SetTokenFcm = async () => {
            const setFcm = await SetFcm()
            localStorage.setItem('fcm', setFcm)
        }
        SetTokenFcm()
    }, [])

    return (
        <Box bg="blackAlpha.100" pt="80px" h={'100vh'}>
            <Navbar appName={props.appName} />
            <Sidebar
                items={props.items}
                activeNum={props.activeNum}
                backUrl={props.backUrl}
            />
            <Box ml={'260px'}>
                <Box pos={'relative'}>{props.children}</Box>
                {/* <Network /> */}
            </Box>
        </Box>
    )
}

export default Root
