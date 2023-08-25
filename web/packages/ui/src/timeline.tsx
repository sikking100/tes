import {
    Flex,
    Box,
    Text,
    HStack,
    VStack,
    Divider,
    SimpleGrid,
} from '@chakra-ui/layout'
import React from 'react'
import { Shared } from '.'
import { Avatar } from '@chakra-ui/avatar'
import { entity } from './utils'
import { StatusUserApprover } from 'apis'

interface Props {
    children: React.ReactNode
    date: string
    index: number
    arrLen: number
}

export const TimeLines: React.FC<Props> = (props) => {
    const { arrLen, date, index, children } = props
    return (
        <Flex alignItems="center" minH="100px" justifyContent="start">
            <Flex direction="column" h="100%">
                <Box
                    boxSize={'10px'}
                    rounded={'full'}
                    bg="gray.200"
                    ml={'-3.6px'}
                />
                <Box
                    w="2px"
                    bg="gray.200"
                    h={index === arrLen - 1 ? '15px' : '100%'}
                />
            </Flex>
            <Flex
                direction="column"
                justifyContent="flex-start"
                h="100%"
                pl={2}
            >
                <Box fontSize="sm">{children}</Box>
                <Text fontSize="sm" color="gray.400" fontWeight="normal">
                    {Shared.FormatDateToString(date)}
                </Text>
            </Flex>
        </Flex>
    )
}

interface ITimeLineApproval {
    dataLenght: number
    idx: number
    imageUrl: string
    name: string
    roles: string
    updatedAt: string
    status: number
    note: string
}
export const TimeLineApproval: React.FC<ITimeLineApproval> = (props) => {
    const status = Number(props.status)

    return (
        <Box>
            <SimpleGrid columns={2} gap={3}>
                <HStack>
                    <Avatar src={props.imageUrl} />
                    <Box>
                        <Text fontSize={'sm'}>{props.name}</Text>
                        <Text fontWeight={'semibold'} fontSize={'xs'}>
                            {entity.roles(Number(props.roles))}
                        </Text>
                    </Box>
                </HStack>
                <VStack align={'start'} w="200px">
                    <Text fontWeight={'bold'} fontSize={'xs'}>
                        {entity.statusApply(status)}
                    </Text>
                    <Text fontSize={'sm'}>{props.note || '-'}</Text>
                    <Text fontSize={'sm'}>
                        {status === StatusUserApprover.APPROVE ? (
                            <> {Shared.FormatDateToString(props.updatedAt)}</>
                        ) : (
                            '-'
                        )}
                    </Text>
                </VStack>
            </SimpleGrid>
            <Divider />
        </Box>
    )
}
