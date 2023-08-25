import { Box, Flex, Icon, Text } from '@chakra-ui/react'
import {
    IoMdCheckmarkCircle,
    IoMdAlert,
    IoIosCloseCircleOutline,
} from 'react-icons/io'
import { ImSpinner8 } from 'react-icons/im'

export type IStatus = 'success' | 'info' | 'warning' | 'error' | 'loading'

export interface IToast {
    title: React.ReactNode
    description: React.ReactNode
    status: IStatus
}

export const Toast = (props: IToast) => {
    return (
        <>
            <Flex h="100%" bg="white" overflow="hidden">
                <Flex
                    justifyContent="center"
                    alignItems="center"
                    w={'60px'}
                    h="66px"
                    bg={
                        props.status === 'success'
                            ? 'green.500'
                            : props.status === 'info'
                            ? 'blue.500'
                            : props.status === 'warning'
                            ? 'yellow.500'
                            : props.status === 'loading'
                            ? 'blue.500'
                            : 'red.500'
                    }
                >
                    <Icon
                        as={
                            props.status === 'success'
                                ? IoMdCheckmarkCircle
                                : props.status === 'info'
                                ? IoMdAlert
                                : props.status === 'warning'
                                ? IoMdAlert
                                : props.status === 'loading'
                                ? ImSpinner8
                                : IoIosCloseCircleOutline
                        }
                        color="white"
                        boxSize={8}
                    />
                </Flex>

                <Box mx={-3} py={2} px={4}>
                    <Box
                        mx={3}
                        display="flex"
                        margin="auto"
                        alignItems={'center'}
                        justifyContent={'center'}
                        h="full"
                    >
                        <Text
                            as={'span'}
                            pl="5px"
                            color="gray.600"
                            _dark={{
                                color: 'gray.200',
                            }}
                            fontSize="15px"
                            textTransform="capitalize"
                        >
                            {props.description}
                        </Text>
                    </Box>
                </Box>
            </Flex>
        </>
    )
}
