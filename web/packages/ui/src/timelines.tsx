import React from 'react'
import {
    Box,
    chakra,
    Container,
    Link,
    Text,
    HStack,
    VStack,
    Flex,
    Icon,
    useColorModeValue,
} from '@chakra-ui/react'
// Here we have used react-icons package for the icons
import { FaRegNewspaper } from 'react-icons/fa'
import { BsGithub } from 'react-icons/bs'
import { IconType } from 'react-icons'
import { Delivery } from 'apis'
import { entity } from './utils'
import { Shared } from '.'

const milestones = [
    {
        id: 1,
        categories: ['Article'],
        title: 'Wrote first article on Medium',
        icon: FaRegNewspaper,
        description: `Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum is simply dummy text of the printing and typesetting industry. `,
        date: 'MARCH 30, 2022',
    },
    {
        id: 2,
        categories: ['Web Dev', 'OSS'],
        title: 'First open source contribution',
        icon: BsGithub,
        description: `Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.`,
        date: 'July 30, 2022',
    },
]

interface TimelineProps {
    data: Delivery[]
}

const Milestones: React.FC<TimelineProps> = ({ data }) => {
    return (
        <Box maxWidth="4xl">
            {data.map((milestone, index) => (
                <Flex key={index} mb="10px">
                    <LineWithDot />
                    <Card {...milestone} />
                </Flex>
            ))}
        </Box>
    )
}

interface CardProps {
    title: string
    categories: string[]
    description: string
    icon: IconType
    date: string
}

const Card = ({
    note,
    courier,
    product,
    courierType,
    customer,
    status,
    createdAt,
}: Delivery) => {
    return (
        <HStack
            px={4}
            w={'50%'}
            shadow={'md'}
            spacing={1}
            rounded="lg"
            alignItems="center"
            pos="relative"
        >
            <Box>
                <VStack mb={3} textAlign="left" align={'start'}>
                    <chakra.p
                        as={Link}
                        _hover={{ color: 'teal.400' }}
                        lineHeight={1.2}
                        fontWeight="bold"
                        w="100%"
                    >
                        {entity.statusDeliver(status)}
                    </chakra.p>
                    <HStack>
                        <chakra.p>Dipesan oleh</chakra.p>
                        <chakra.p fontWeight={'bold'} cursor={'pointer'}>
                            {customer?.name}
                        </chakra.p>
                    </HStack>
                    <HStack>
                        <chakra.p> Diantar oleh </chakra.p>
                        <chakra.p fontWeight={'bold'} cursor={'pointer'}>
                            {courier?.name ?? '-'}
                        </chakra.p>
                    </HStack>
                </VStack>
                <Text fontSize="sm">
                    {Shared.FormatDateToString(createdAt)}
                </Text>
            </Box>
        </HStack>
    )
}

const LineWithDot = () => {
    return (
        <Flex pos="relative" alignItems="center" mr="40px">
            <chakra.span
                position="absolute"
                left="50%"
                height="calc(100% + 10px)"
                border="1px solid"
                borderColor={useColorModeValue('gray.200', 'gray.700')}
                top="0px"
            ></chakra.span>
            <Box pos="relative" p="10px">
                <Box
                    pos="absolute"
                    width="100%"
                    height="100%"
                    bottom="0"
                    right="0"
                    top="0"
                    left="0"
                    backgroundSize="cover"
                    backgroundRepeat="no-repeat"
                    backgroundPosition="center center"
                    backgroundColor="red"
                    borderRadius="100px"
                    border="2px solid red"
                    backgroundImage="none"
                    opacity={1}
                ></Box>
            </Box>
        </Flex>
    )
}

export default Milestones
