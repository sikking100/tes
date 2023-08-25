import { HStack } from '@chakra-ui/react'
import React from 'react'
import { orderService, store } from 'hooks'
import { Buttons, ButtonTooltip, Columns, Icons, PagingButton, PText, Root, Tables, Types } from 'ui'
import { Customers, Order, OrderStatus, PriceProducts, getCustomerApiInfo, getProdcutApiInfo } from 'apis'
import { dataListOrder } from '~/navigation'
import { useNavigate } from 'react-router-dom'
import DetailOrder from './detail-order'
import OrderApplyDetail from '../apply/order-apply-detail'
import FilterOrder from './filter-oder'
import { create } from 'zustand'
import { CreateProductOrder } from 'apis/services/order/order'

const Wrap: React.FC<{ children: React.ReactNode }> = ({ children }) => (
    <Root appName="Sales" items={dataListOrder} backUrl={'/'} activeNum={2}>
        {children}
    </Root>
)

interface ReOrder {
    order?: Order | null
    customer?: Customers | null
    product?: CreateProductOrder[]
    setOrder: (req: { order: Order; customer: Customers; product: CreateProductOrder[] }) => void
}

export const reOrderState = create<ReOrder>((set) => ({
    order: null,
    product: [],
    customer: null,
    setOrder: ({ order, customer, product }) => set({ order, product, customer }),
}))

const MyOrderPages = () => {
    const navigate = useNavigate()
    const setOrder = reOrderState((v) => v.setOrder)
    const [isOpenFilter, setOpenFilter] = React.useState(false)
    const admin = store.useStore((i) => i.admin)
    const { data, error, isLoading, page, onSetQuery } = orderService.useGetOrder()
    const { column, isOpen, selectData, setOpen, isOpenOlOd, setOpenOlOd } = columns()

    React.useEffect(() => {
        setOrder({ customer: null as unknown as Customers, order: null as unknown as Order, product: [] })
        if (admin) {
            onSetQuery({ userid: admin.id, page: 1 })
        }
    }, [admin])

    return (
        <Wrap>
            {isOpen && selectData && (
                <DetailOrder deliveryId={selectData.deliveryId} idOrder={`${selectData.id}`} isOpen={isOpen} setOpen={setOpen} />
            )}
            {isOpenOlOd && selectData && <OrderApplyDetail id={selectData.id} isOpen={isOpenOlOd} setOpen={setOpenOlOd} />}

            {error ? (
                <PText label={error} />
            ) : (
                <>
                    {/* <Box bg="white" px={2} pt={1} mb={'10px'} experimental_spaceY={2}>
                        <Buttons
                            leftIcon={<Icons.AddIcons fontSize={22} />}
                            label={'Buat Pesanan'}
                            onClick={() => navigate('/order-create')}
                        />
                        <Divider />
                    </Box> */}
                    <HStack align={'start'} mb={'10px'}>
                        {/* <FilterOrder mt="0px" isOpen={isOpenFilter} onOpen={setOpenFilter} /> */}
                        <Buttons
                            mr={'100px'}
                            leftIcon={<Icons.AddIcons fontSize={22} />}
                            label={'Buat Pesanan'}
                            onClick={() => navigate('/order-create')}
                        />
                    </HStack>
                    <Tables isLoading={isLoading} columns={column} data={isLoading ? [] : data.items} />
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
    const cols = Columns.columnsOrder
    const priceOfProduct = new PriceProducts()
    const [loadingReOrder, setLoadingReOrder] = React.useState(false)
    const [idLoading, setIdLoading] = React.useState('')
    const [selectData, setSelectData] = React.useState<Order>()
    const [isOpen, setOpen] = React.useState(false)
    const [isOpenOlOd, setOpenOlOd] = React.useState(false)
    const setOrder = reOrderState((i) => i.setOrder)
    const navigate = useNavigate()

    const onSetReOder = async (req: { customerId: string; order: Order }) => {
        setIdLoading(req.order.id)
        setLoadingReOrder(true)
        try {
            const dataProduct: CreateProductOrder[] = []
            const customer = await getCustomerApiInfo().findCustomerById(req.customerId)
            for await (const i of req.order.product) {
                const resProduct = await getProdcutApiInfo().findProductBranchById(`${req.order.branchId}-${i.id}`)
                dataProduct.push({
                    id: resProduct.productId,
                    name: resProduct.name,
                    description: resProduct.description,
                    qty: i.qty,
                    team: resProduct.category.team,
                    discount: priceOfProduct.getDiscount({
                        idPriceList: `${customer.business.priceList.id}`,
                        qty: i.qty,
                        priceList: resProduct.price,
                    }),
                    brandId: resProduct.brand.id,
                    brandName: resProduct.brand.name,
                    categoryId: resProduct.category.id,
                    categoryName: resProduct.category.name,
                    point: resProduct.point,
                    totalPrice: priceOfProduct.getDiscount({
                        idPriceList: `${customer.business.priceList.id}`,
                        qty: i.qty,
                        priceList: resProduct.price,
                    }),
                    imageUrl: resProduct.imageUrl,
                    tax: 0,
                    unitPrice: priceOfProduct.getPriceOfProduct({
                        idPriceList: `${customer.business.priceList.id}`,
                        priceList: resProduct.price,
                        qty: 1,
                    }),
                    salesId: resProduct.salesId,
                    salesName: resProduct.salesName,
                    size: resProduct.size,
                    additional: 0,
                })
            }
            setOrder({
                customer: customer,
                order: req.order,
                product: dataProduct,
            })
            navigate({ pathname: '/order-create' })
        } catch (e) {
            //
        } finally {
            setIdLoading('')

            setLoadingReOrder(false)
        }
    }

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
                        isLoading={loadingReOrder && v.id === idLoading}
                        label={'Pesan Ulang'}
                        icon={<Icons.IconRotate color={'gray'} />}
                        onClick={() => {
                            onSetReOder({ customerId: v.customer.id, order: v })
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

export default MyOrderPages
