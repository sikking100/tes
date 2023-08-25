import React from 'react'
import { Table, Tbody, Td, Th, Thead, Tr } from '@chakra-ui/table'
import { Box } from '@chakra-ui/layout'
import { Skeleton } from '@chakra-ui/skeleton'
import { TableProps } from './types'

export function Tables<T extends object>(props: TableProps<T>) {
    return (
        <BoxTables
            usePaging={!!props.usePaging}
            pageH={props.pageH}
            useTab={props.useTab}
        >
            <Table size={'sm'} p={0} w={'full'}>
                <Thead>
                    <Tr p={0}>
                        {props.columns.map((c, k) => (
                            <Th
                                px={0}
                                pl={2}
                                w={c.width || '200px'}
                                shadow={'none'}
                                key={k}
                                fontSize={{
                                    sm: '10px !important',
                                    xl: '13px !important',
                                }}
                                fontWeight="bold"
                                position="sticky"
                                bg={'white'}
                                top="0"
                                zIndex="1"
                                h={'50px'}
                            >
                                <Box>
                                    <>{c.header}</>
                                </Box>
                            </Th>
                        ))}
                    </Tr>
                </Thead>
                <Tbody>
                    {props.isLoading ? (
                        <>
                            {[1, 2, 3, 4, 5].map((it, id) => (
                                <Tr
                                    key={id}
                                    _hover={{ bg: 'gray.50' }}
                                    bg={'white'}
                                    fontWeight={'medium'}
                                >
                                    {props.columns.map((col, key) => (
                                        <Td key={key} pl={2}>
                                            <Skeleton
                                                height="15px"
                                                rounded={'md'}
                                            />
                                        </Td>
                                    ))}
                                </Tr>
                            ))}
                        </>
                    ) : (
                        <>
                            {props.data?.map((it, id) => (
                                <Tr
                                    key={id}
                                    _hover={{ bg: 'gray.50' }}
                                    bg={'white'}
                                    fontWeight={'medium'}
                                >
                                    {props.columns.map((col, key) => (
                                        <Td
                                            key={key}
                                            fontSize={'sm'}
                                            pl={2}
                                            w={col.width || '200px'}
                                        >
                                            <Box
                                                fontSize={{
                                                    sm: '10px !important',
                                                    xl: '13px !important',
                                                    '2xl': '13px !important',
                                                }}
                                            >
                                                <> {col.render(it)}</>
                                            </Box>
                                        </Td>
                                    ))}
                                </Tr>
                            ))}
                        </>
                    )}
                </Tbody>
            </Table>
        </BoxTables>
    )
}

export const BoxTables: React.FC<{
    children: React.ReactNode
    usePaging: boolean
    pageH?: string
    useTab?: boolean
}> = ({ children, pageH, useTab }) => {
    const setHeight = () => {
        if (pageH) {
            return pageH
        }

        if (window.screen.availWidth >= 1920) {
            if (useTab) return '74vh'
            return '80vh'
        }
        if (window.screen.availWidth >= 1535) {
            if (useTab) return '66vh'
            return '74vh'
        }
        if (window.screen.availWidth >= 1440) {
            if (useTab) return '64vh'
            return '70vh'
        }
        if (window.screen.availWidth >= 1366) {
            if (useTab) return '61vh'
            return '70vh'
        }

        return '100%'
    }

    const setCallHeight = React.useMemo(setHeight, [window.screen.availWidth])

    return (
        <Box
            borderBottomRadius={'7px'}
            borderTopRadius={'7px'}
            bg="white"
            overflow={'auto'}
            mb={'5px'}
            minH={setCallHeight}
            maxH={setCallHeight}
            pos={'relative'}
            overflowX={'auto'}
        >
            <>{children}</>
        </Box>
    )
}

//
