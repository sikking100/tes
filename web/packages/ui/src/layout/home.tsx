import React from 'react'
import {
    Box,
    Center,
    HStack,
    SimpleGrid,
    Text,
    VStack,
    Avatar,
    SkeletonCircle,
    Skeleton,
} from '@chakra-ui/react'
import { Link, useNavigate } from 'react-router-dom'
import { store, useAuth } from 'hooks'

import { ButtonForm, Buttons, Modals } from '..'
import Navbar from './navbar'
import { appName, ListItemProps } from '../types'

interface HomeProps {
    appName: appName
    list: ListItemProps[]
    isLoading?: boolean
}

const PADDING =
    window.screen.availWidth >= 1535
        ? 100
        : window.screen.availWidth >= 1000
        ? 10
        : 10

const Home: React.FC<HomeProps> = ({ appName, list, isLoading }) => {
    const [isOpen, setOpen] = React.useState(false)
    const adminInfo = store.useStore((i) => i.admin)
    const navigate = useNavigate()
    const { logout } = useAuth()

    React.useEffect(() => {
        document.body.style.overflow = 'hidden'
    }, [])

    const handleLogout = () => {
        logout()
        navigate('/login', { replace: true })
    }

    const setListItems = React.useMemo(() => {
        if (list.length > 3) {
            return (
                <React.Fragment>
                    {list.map((it, id, lgx) => {
                        if (id === 3) {
                            return (
                                <div key={id}>
                                    <Box />
                                    <Link key={id} to={it.link} rel="noopener">
                                        <HStack
                                            shadow={'md'}
                                            bg={'white'}
                                            h={'100px'}
                                            rounded={'xl'}
                                        >
                                            <Center
                                                bg={it.color}
                                                h={'100%'}
                                                w={'100px'}
                                                rounded={'xl'}
                                            >
                                                <Center
                                                    rounded={'full'}
                                                    bg={'white'}
                                                    w={50}
                                                    h={50}
                                                >
                                                    <>{it.icon}</>
                                                </Center>
                                            </Center>
                                            <Text
                                                fontSize={'20px'}
                                                fontWeight={'600'}
                                                pl={10}
                                            >
                                                {it.text}
                                            </Text>
                                        </HStack>
                                    </Link>
                                    <Box />
                                </div>
                            )
                        }
                        return (
                            <Link key={id} to={it.link} rel="noopener">
                                <HStack
                                    shadow={'md'}
                                    bg={'white'}
                                    h={'100px'}
                                    rounded={'xl'}
                                >
                                    <Center
                                        bg={it.color}
                                        h={'100%'}
                                        w={'100px'}
                                        rounded={'xl'}
                                    >
                                        <Center
                                            rounded={'full'}
                                            bg={'white'}
                                            w={50}
                                            h={50}
                                        >
                                            <>{it.icon}</>
                                        </Center>
                                    </Center>
                                    <Text
                                        fontSize={'20px'}
                                        fontWeight={'600'}
                                        pl={10}
                                    >
                                        {it.text}
                                    </Text>
                                </HStack>
                            </Link>
                        )
                    })}
                </React.Fragment>
            )
        }

        return (
            <React.Fragment>
                {list.map((it, id) => (
                    <Link key={id} to={it.link} rel="noopener">
                        <HStack
                            shadow={'md'}
                            bg={'white'}
                            h={'100px'}
                            rounded={'xl'}
                        >
                            <Center
                                bg={it.color}
                                h={'100%'}
                                w={'100px'}
                                rounded={'xl'}
                            >
                                <Center
                                    rounded={'full'}
                                    bg={'white'}
                                    w={50}
                                    h={50}
                                >
                                    <>{it.icon}</>
                                </Center>
                            </Center>
                            <Text fontSize={'20px'} fontWeight={'600'} pl={10}>
                                {it.text}
                            </Text>
                        </HStack>
                    </Link>
                ))}
            </React.Fragment>
        )
    }, [])

    return (
        <Box>
            <Navbar pos="relative" appName={appName} />
            <Box bg="gray.100" h={'100vh'} overflow={'hidden'}>
                {isOpen && (
                    <Modals title={'Logout'} setOpen={setOpen} isOpen={isOpen}>
                        <Text fontWeight={500} fontSize={'lg'}>
                            Yakin ingin keluar dari {appName} Administrator ?
                        </Text>
                        <ButtonForm
                            isLoading={false}
                            label="Ya"
                            labelClose="Tidak"
                            onClose={() => setOpen(false)}
                            onClick={handleLogout}
                        />
                    </Modals>
                )}
                <Box
                    pos={'absolute'}
                    top={'50%'}
                    left={'50%'}
                    transform={'translate(-50%, -50%)'}
                    px={PADDING}
                    justifyContent={'center'}
                    alignItems={'center'}
                    w={window.screen.width - 100}
                >
                    {isLoading ? (
                        <Skeleton h={'50px'} />
                    ) : (
                        <React.Fragment>
                            <SimpleGrid
                                row={3}
                                gap={
                                    window.screen.availWidth >= 1535
                                        ? '30px'
                                        : '23px'
                                }
                            >
                                <VStack mb={3}>
                                    {!adminInfo ? (
                                        <SkeletonCircle
                                            size="20"
                                            id="img-skeleton"
                                        />
                                    ) : (
                                        <Avatar
                                            w={'150px'}
                                            h={'150px'}
                                            rounded={'full'}
                                            src={adminInfo?.imageUrl}
                                            objectFit={'contain'}
                                        />
                                    )}
                                    <Text
                                        fontWeight={700}
                                        textAlign={'center'}
                                        fontSize={20}
                                        mt={4}
                                        pl={3}
                                    >
                                        {adminInfo?.name}
                                    </Text>

                                    {Number(adminInfo?.roles) > 3 &&
                                    Number(adminInfo?.roles) < 8 ? (
                                        <Text
                                            fontWeight={500}
                                            textAlign={'center'}
                                            fontSize={18}
                                            mt={4}
                                            pl={3}
                                        >
                                            {adminInfo?.location.name}
                                        </Text>
                                    ) : null}
                                </VStack>

                                <SimpleGrid
                                    columns={3}
                                    gap={
                                        window.screen.availWidth >= 1920 ? 6 : 3
                                    }
                                >
                                    {setListItems}
                                </SimpleGrid>
                                <div />

                                <Center>
                                    <Buttons
                                        label="Logout"
                                        w={'180px'}
                                        shadow={'md'}
                                        bg="red.100"
                                        onClick={() => setOpen(true)}
                                    />
                                </Center>
                            </SimpleGrid>
                        </React.Fragment>
                    )}
                </Box>
            </Box>
        </Box>
    )
}

export default React.memo(Home)
