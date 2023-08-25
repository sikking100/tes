import React from 'react'
import { dataListProduct } from '~/navigation'
import { PText, PagingButton, Root, Tables, Columns, Types } from 'ui'
import { store, productService, setHeight } from 'hooks'
import { ProductTypes } from 'apis'
import { Box, Text } from '@chakra-ui/react'

const Wrap: React.FC<{ children: React.ReactNode }> = ({ children }) => (
    <Root appName="Warehouse" items={dataListProduct} backUrl={'/'} activeNum={2}>
        {children}
    </Root>
)

const QtyHistoryPages = () => {
    const height = setHeight()

    const admin = store.useStore((i) => i.admin)
    const { column } = columns()
    const { data, page, setPage, error, isLoading } = productService.useGetProductHistory({
        branchId: `${admin?.location.id}`,
    })
    return (
        <Wrap>
            {error ? (
                <PText label={error} />
            ) : (
                <Tables columns={column} usePaging={true} pageH={height} isLoading={isLoading} data={isLoading ? [] : data.items} />
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

    const column: Types.Columns<ProductTypes.HistoryQty>[] = [
        cols.name,
        cols.brand,
        cols.branchId,
        cols.category,
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
