import React, { FC, memo } from 'react'
import { HamburgerIcon } from '@chakra-ui/icons'
import { Box, Heading, IconButton, SimpleGrid } from '@chakra-ui/react'
import { Link } from 'react-router-dom'
import { Images } from '../images'
import DfImageWhite from '../../assets/logo-white-df.webp'
import { appName } from '../types'
import { store } from 'hooks'
import { entity } from '../utils'

interface NavbarProps {
    pos?: 'relative'
    appName: appName
}

const Navbar: FC<NavbarProps> = ({ pos, appName }) => {
    const adminInfo = store.useStore((i) => i.admin)

    const setRoles = React.useCallback(() => {
        let appname = ''

        switch (String(adminInfo?.roles)) {
            case entity.RolesEntity.SYSTEM_ADMIN:
                appname = 'System'
                break
            case entity.RolesEntity.FINANCE_ADMIN:
                appname = 'Finance'
                break
            case entity.RolesEntity.SALES_ADMIN:
                appname = 'Sales'
                break
            case entity.RolesEntity.BRANCH_ADMIN:
                appname = 'Branch'
                break
            case entity.RolesEntity.BRANCH_FINANCE_ADMIN:
                appname = 'Branch Finance'
                break
            case entity.RolesEntity.BRANCH_SALES_ADMIN:
                appname = 'Branch Sales'
                break
            case entity.RolesEntity.WAREHOUSE_ADMIN:
                appname = 'Warehouse'
                break
            default:
                break
        }

        return appname
    }, [adminInfo])

    return (
        <Box
            as={'nav'}
            bg="red.100"
            w="100%"
            pos={pos || 'fixed'}
            top={0}
            left={0}
            h={'70px'}
            zIndex={20}
            shadow={'xl'}
        >
            <SimpleGrid columns={3} px={7} py={3}>
                <Images
                    src={DfImageWhite}
                    w={'180px'}
                    height={'auto'}
                    alt="image-navbar"
                    loading="lazy"
                />
                <Heading
                    fontWeight={600}
                    fontSize={{ sm: '20px', lg: '30px' }}
                    color={'white'}
                    textAlign={'center'}
                >
                    {`${setRoles()} Administrator`}
                </Heading>
                <Box ml={'auto'} mr={0} w={'fit-content'} right={0}>
                    <Link to={'/profile'} rel="noopener">
                        <IconButton
                            aria-label="icon"
                            bg={'transparent'}
                            icon={<HamburgerIcon fontSize={'25px'} />}
                        />
                    </Link>
                </Box>
            </SimpleGrid>
        </Box>
    )
}

export default memo(Navbar)
