import React from 'react'
import { ButtonTooltip, Columns, Icons, PagingButton, PText, Root, SearchInput, Tables, Types } from 'ui'
import DetailOrder from './detail-order'
import { orderService } from 'hooks'
import { dataListOrder } from '~/navigation'
import { Order, OrderStatus } from 'apis'
import { HStack } from '@chakra-ui/react'
import { getOrderById } from './function'
import { createPortal } from 'react-dom'
import OrderApplyDetail from '../apply/order-apply-detail'
import FilterOrder from './filter-oder'
import { useSearchParams } from 'react-router-dom'

const Wrap: React.FC<{ children: React.ReactNode }> = ({ children }) => (
    <Root appName="Sales" items={dataListOrder} backUrl={'/'} activeNum={1}>
        {children}
    </Root>
)

const OrderPages = () => {
    const [query] = useSearchParams()
    const { data, error, isLoading, page, onSetQuery } = orderService.useGetOrder()
    const { column, isOpen, selectData, setOpen, isOpenOlOd, setOpenOlOd } = columns()
    const [isOpenFilter, setOpenFilter] = React.useState(false)
    const [orderData, setOrderData] = React.useState<Order[]>([])
    const [loadingOrder, setLoadingOrder] = React.useState(false)

    React.useEffect(() => {
        if (query) {
            onSetQuery({
                code: query.get('code') || '',
                status: Number(query.get('status')) || undefined,
            })
        }
    }, [query])

    const onSearchOrder = (v: string) => {
        if (v.length < 10) {
            setOrderData([])
            return
        }
        getOrderById({
            id: v,
            setLoading: setLoadingOrder,
            setOrderData,
        })
    }

    return (
        <Wrap>
            {isOpen && selectData && (
                <>
                    {createPortal(
                        <DetailOrder deliveryId={selectData.deliveryId} idOrder={`${selectData.id}`} isOpen={isOpen} setOpen={setOpen} />,
                        document.body
                    )}
                </>
            )}

            {isOpenOlOd && selectData && <OrderApplyDetail id={selectData.id} isOpen={isOpenOlOd} setOpen={setOpenOlOd} />}

            {error ? (
                <PText label={error} />
            ) : (
                <>
                    <HStack w="fit-content">
                        <SearchInput placeholder="Ketik Id Pesanan" onChange={(e) => onSearchOrder(e.target.value)} />
                        <FilterOrder isOpen={isOpenFilter} onOpen={setOpenFilter} />
                    </HStack>

                    {/**/}
                    <Tables isLoading={isLoading || loadingOrder} columns={column} data={orderData.length > 0 ? orderData : data?.items} />
                    <PagingButton
                        page={Number(page)}
                        nextPage={() => onSetQuery({ page: Number(page) + 1 })}
                        prevPage={() => onSetQuery({ page: Number(page) - 1 })}
                        disableNext={data?.next === null}
                    />
                </>
            )}
        </Wrap>
    )
}

const columns = () => {
    const [selectData, setSelectData] = React.useState<Order>()
    const [isOpen, setOpen] = React.useState(false)
    const [isOpenOlOd, setOpenOlOd] = React.useState(false)
    const cols = Columns.columnsOrder

    const column: Types.Columns<Order>[] = [
        cols.id,
        cols.customer,
        cols.creator,
        cols.product,
        cols.status,
        cols.createdAt,
        {
            header: 'Aksi',
            render: (v) => (
                <HStack>
                    <ButtonTooltip
                        label={'Detail'}
                        icon={<Icons.IconDetails color={'gray'} />}
                        onClick={() => {
                            setOpen(true)
                            setSelectData(v)
                        }}
                    />
                    <ButtonTooltip
                        isDisabled={v.status === OrderStatus.APPLY ? false : true}
                        label={'Detail OL / OD'}
                        icon={<Icons.IconEye color={'gray'} />}
                        onClick={() => {
                            setOpenOlOd(true)
                            setSelectData(v)
                        }}
                    />
                </HStack>
            ),
        },
    ]

    return {
        column,
        selectData,
        isOpen,
        setOpen,
        isOpenOlOd,
        setOpenOlOd,
    }
}

export default OrderPages
