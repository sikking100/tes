import React, { useTransition } from 'react'
import {
    Box,
    HStack,
    Text,
    VStack,
    SkeletonCircle,
    Avatar,
} from '@chakra-ui/react'
import { Link, useNavigate } from 'react-router-dom'
import { store } from 'hooks'
import { Buttons } from '../button'
import { SidebarProps } from '../types'

const Sidebar: React.FC<SidebarProps> = ({
    activeNum,
    backUrl,
    items,
}: SidebarProps) => {
    const [startTransition] = useTransition()
    const navigate = useNavigate()
    const adminInfo = store.useStore((v) => v.admin)

    const PADDING =
        window.screen.availWidth >= 1535
            ? '100%'
            : window.screen.availWidth >= 1000
            ? '250px'
            : '250px'

    return (
        <Box
            data-testid={'sidebar-id'}
            bg="red.200"
            m="0"
            p="0"
            w="250px"
            position={'fixed'}
            h={'100%'}
            overflow="auto"
            shadow="2xl"
            left="0"
            top="0"
        >
            <VStack align={'stretch'}>
                {/* Image Profile */}
                <VStack m={'auto'} mt={'100px'} mb={'15px'}>
                    {!adminInfo ? (
                        <SkeletonCircle size="20" />
                    ) : (
                        <Avatar
                            w={'100px'}
                            h={'100px'}
                            rounded={'full'}
                            src={adminInfo?.imageUrl}
                        />
                    )}

                    <Text color="white" textAlign={'center'} mt={4}>
                        {adminInfo?.name}
                    </Text>
                </VStack>
                {/* List Item */}
                <VStack
                    align={'start'}
                    w={'full'}
                    minH={PADDING}
                    maxH={PADDING}
                    overflow={'auto'}
                >
                    {items?.map((it, id) => (
                        <Link
                            key={id}
                            role={'link'}
                            to={it.link}
                            data-testid={`react-link-${it.title}`}
                            rel="noopener"
                        >
                            <HStack
                                w={'250px'}
                                spacing={5}
                                bg={
                                    it.id === activeNum
                                        ? 'white'
                                        : 'transparent'
                                }
                            >
                                <Box
                                    w={1}
                                    bg={
                                        it.id === activeNum
                                            ? 'yellow.100'
                                            : 'transparent'
                                    }
                                    h="50"
                                />
                                <Text
                                    fontWeight={'400'}
                                    color={
                                        it.id === activeNum ? 'black' : 'white'
                                    }
                                >
                                    {it.title}
                                </Text>
                            </HStack>
                        </Link>
                    ))}
                </VStack>
            </VStack>
            {/* Back Button */}
            <div
                style={{
                    display: 'flex',
                    position: 'fixed',
                    bottom: 10,
                    left: 20,
                }}
            >
                <Buttons
                    id="button-back"
                    bg="yellow.100"
                    w={200}
                    color={'black'}
                    label={'Kembali'}
                    onClick={() => navigate(String(backUrl), { replace: true })}
                />
            </div>
        </Box>
    )
}

export default Sidebar
