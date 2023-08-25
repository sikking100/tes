import React from 'react'
import { Columns, PText, PagingButton, Root, Tables, Types, entity } from 'ui'
import ModalsSelectBranch, { SearchInputInTag } from '../../tag/modal-search-branch'
import { useSearchParams } from 'react-router-dom'
import CardDetailBranch from '../../tag/card-detail-branch'
import { dataListProduct } from '~/navigation'
import { productService } from 'hooks'
import { HistoryQty } from 'apis/services/product/types'
import { Box, HStack, Text } from '@chakra-ui/react'

const Wrap: React.FC<{ children: React.ReactNode }> = ({ children }) => {
    return (
        <Root appName="System" items={dataListProduct} backUrl={'/'} activeNum={5}>
            {children}
        </Root>
    )
}

export const setHeight = () => {
    if (window.screen.availWidth >= 1920) {
        return '72vh'
    }
    if (window.screen.availWidth >= 1535) {
        return '64vh'
    }
    if (window.screen.availWidth >= 1440) {
        return '60vh'
    }
    if (window.screen.availWidth >= 1366) {
        return '59vh'
    }

    return '100%'
}

const QtyHistoryPages = () => {
    const [searchParams] = useSearchParams()
    const { column } = columns()
    const [isOpenBranch, setOpenBranch] = React.useState(true)
    const { data, setQ, page, setPage, error, isLoading } = productService.useGetProductHistory({
        branchId: searchParams.get('branchId') || '',
    })

    return (
        <Wrap>
            <ModalsSelectBranch isOpenBranch={isOpenBranch} setOpenBranch={setOpenBranch} />
            <HStack w={'full'}>
                <Box w={'500px'}>
                    <CardDetailBranch type="qty" />
                </Box>
                <SearchInputInTag prefix="qty-history" label="History" setOpenBranch={setOpenBranch} setQ={setQ} />
            </HStack>

            {error ? (
                <PText label={error} />
            ) : (
                <Tables columns={column} isLoading={isLoading} data={isLoading ? [] : data.items} pageH={setHeight()} />
            )}
            <PagingButton
                page={page}
                nextPage={() => setPage(page + 1)}
                prevPage={() => setPage(page - 1)}
                disableNext={data?.next === null}
            />
        </Wrap>
    )
}

export default QtyHistoryPages

const columns = () => {
    const cols = Columns.columnsQtyHistory
    const [isOpen, setOpen] = React.useState(false)

    const column: Types.Columns<HistoryQty>[] = [
        cols.name,
        cols.brand,
        cols.branchId,
        cols.category,
        {
            header: 'Tim',
            render: (v) => <Text>{entity.team(String(v.category.team))}</Text>,
            width: '200px',
        },
        cols.qty,
        {
            header: 'Asal',
            render: (v) => {
                const find = v.warehouse.filter((v) => v !== null)[0]
                const to = v.warehouse.filter((v) => v !== null)[1]

                return (
                    <Box>
                        {to ? (
                            <>
                                <Text>{find?.name}</Text>
                                <Text>{find?.qty}</Text>
                            </>
                        ) : (
                            '-'
                        )}
                    </Box>
                )
            },
        },
        {
            header: 'Tujuan',
            render: (v) => {
                const to = v.warehouse.filter((v) => v !== null)[1]
                const from = v.warehouse.filter((v) => v !== null)[0]

                return (
                    <Box>
                        {!to ? (
                            <>
                                <Text>{from?.name}</Text>
                                <Text>{from?.qty}</Text>
                            </>
                        ) : (
                            <>
                                <Text>{to?.name}</Text>
                                <Text>{to?.qty}</Text>
                            </>
                        )}
                    </Box>
                )
            },
        },
        cols.createdAt,
    ]

    return { column, isOpen, setOpen }
}
