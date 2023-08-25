import React from 'react'
import {
    ButtonTooltip,
    Buttons,
    Icons,
    LoadingForm,
    Modals,
    PText,
    PagingButton,
    Root,
    Shared,
    StackAvatar,
    Tables,
    TabsComponent,
    Types,
    entity,
    useToast,
} from 'ui'
import {
    Delivery,
    TypeReqDelivery,
    ProductDelivery,
    Branch,
    Warehouse,
    Courier,
    StatusDelivery,
    getProdcutApiInfo,
    Eroles,
    getCustomerApiInfo,
    CourierType,
    Order,
} from 'apis'
import { dataListOrder } from '~/navigation'
import {
    Avatar,
    Badge,
    Box,
    Button,
    Divider,
    HStack,
    Input,
    InputGroup,
    InputRightElement,
    Skeleton,
    TabPanel,
    Text,
    VStack,
} from '@chakra-ui/react'
import { store, deliveryService, branchService, employeeService, orderService } from 'hooks'
import Select from 'react-select'
import { useNavigate, useSearchParams } from 'react-router-dom'
import { z } from 'zod'

const Wrap: React.FC<{ children: React.ReactNode }> = ({ children }) => (
    <Root appName="Warehouse" items={dataListOrder} backUrl={'/'} activeNum={1}>
        {children}
    </Root>
)

const createPackingListSchema = z.object({
    product: z.array(
        z.object({
            warehouse: z
                .object({
                    id: z.string(),
                    name: z.string(),
                    addressName: z.string(),
                    addressLngLat: z.number().array(),
                })
                .nullable(),
            deliveryQty: z.number().min(0),
        })
    ),
})

interface ICreateDelivery {
    isOpen: boolean
    setOpen: (v: boolean) => void
    data: Delivery
    product: ProductDelivery[]
    branch?: Branch
    dataOrder: Order
}

interface IDelivery {
    isOpen: boolean
    setOpen: (v: boolean) => void
    data: Delivery
    branch?: Branch
    dataOrder: Order
}

const StackInputBtn: React.FC<{
    onClick: (v: number) => void
    isLoading: boolean
    initQty: number
}> = ({ isLoading, onClick, initQty = 0 }) => {
    const [qty, setQty] = React.useState(initQty)
    return (
        <InputGroup size="md">
            <Input
                pr="5rem"
                type="number"
                value={qty}
                onChange={(e) => {
                    const inputQty = Number(e.target.value)
                    setQty(inputQty)
                }}
            />
            <InputRightElement width="4.5rem">
                <Button
                    h="1.75rem"
                    size="sm"
                    rounded={'md'}
                    bg={'red.200'}
                    fontSize={'0.7rem'}
                    fontWeight={'bold'}
                    onClick={() => onClick(qty)}
                    isLoading={isLoading}
                    isDisabled={isLoading}
                >
                    Update
                </Button>
            </InputRightElement>
        </InputGroup>
    )
}

interface IqtyProdct {
    [key: string]: number
}

const CreateDelivery: React.FC<ICreateDelivery> = ({ isOpen, setOpen, product, branch, data, dataOrder }) => {
    const setClose = () => setOpen(false)
    const [dataProduct, setDataProduct] = React.useState<ProductDelivery[]>([])
    const { createPackingList } = deliveryService.useDelivery()
    const [qtyProdct, setQtyProduct] = React.useState<IqtyProdct | null>(null)
    const [loadingGetProduct, setLoadingGetProduct] = React.useState(false)
    const toast = useToast()

    const [qtyReq, setQtyReq] = React.useState({
        productId: '',
        warehouseId: '',
    })

    React.useEffect(() => {
        const newData = product.map((v) => ({
            ...v,
        }))
        setDataProduct(newData)
    }, [])

    React.useEffect(() => {
        if (qtyReq.productId) {
            searchProdcutInBranch(qtyReq)
        }
    }, [qtyReq])

    const onSetWarehouseOnProduct = (productId: string, br: Warehouse) => {
        const newProduct = dataProduct.map((v) => {
            if (v.id === productId) {
                return {
                    ...v,
                    warehouse: {
                        id: br.id,
                        name: br.name,
                        addressName: br.address.name,
                        addressLngLat: br.address.lngLat,
                    },
                }
            }

            return v
        })
        setDataProduct(newProduct)
    }

    const onSetDeliveryQty = (req: { qty: number; productId: string; currentQty: number }) => {
        const newProduct = dataProduct.map((v) => {
            if (v.id === req.productId) {
                if (!v.warehouse) {
                    toast({
                        status: 'error',
                        description: 'Pastikan telah memilih gudang',
                    })
                    return {
                        ...v,
                    }
                }
                if (req.qty > v.purcaseQty) {
                    toast({
                        status: 'error',
                        description: 'Jumlah diantar tidak boleh melebihi jumlah pesanan',
                    })
                    return {
                        ...v,
                    }
                }
                if (req.qty > req.currentQty) {
                    toast({
                        status: 'error',
                        description: 'Jumlah diantar tidak boleh melebihi jumlah stok',
                    })
                    return {
                        ...v,
                    }
                }

                return {
                    ...v,
                    deliveryQty: req.qty,
                }
            }

            return v
        })
        setDataProduct(newProduct)
    }

    const onCreatePackingList = async () => {
        let isHaveWarehouse = false
        let isHaveDeliveryQty = true
        dataProduct.forEach((v) => {
            if (v.warehouse) {
                isHaveWarehouse = true
            }
        })

        const fDataProduct = dataProduct.filter((v) => v.warehouse !== null)
        fDataProduct.forEach((v) => {
            if (!v.deliveryQty) isHaveDeliveryQty = false
        })

        if (!isHaveWarehouse) {
            toast({
                status: 'error',
                description: 'Pastikan telah memilih gudang',
            })
            return
        }

        if (!isHaveDeliveryQty) {
            toast({
                status: 'error',
                description: 'Pastikan memasukkan jumlah diantar',
            })
            return
        }

        createPackingListSchema.parse({
            product: dataProduct,
        })
        await createPackingList.mutateAsync(
            {
                courierType: data.courierType,
                id: data.id,
                product: dataProduct,
            },
            {
                onSuccess: () => {
                    setClose()
                },
            }
        )
    }

    const searchProdcutInBranch = async (req: { productId: string; warehouseId: string }) => {
        try {
            setLoadingGetProduct(true)
            const result = await getProdcutApiInfo().findProductBranchById(req.productId)
            const findProductInWarehouse = result?.warehouse.find((i) => i.id === req.warehouseId)

            setQtyProduct((v) => ({
                ...v,
                [req.productId]: findProductInWarehouse?.qty || 0,
            }))
        } catch (e) {
            console.log(e)
        } finally {
            setLoadingGetProduct(false)
        }
    }

    return (
        <Modals isOpen={isOpen} setOpen={setClose} size="6xl" title="Daftar Pesanan">
            {/*  */}
            <HStack mb={'10px'}>
                <Text fontSize={'16px'}>Catatan:</Text>
                <Text fontWeight={'bold'} fontSize={'16px'}>
                    {dataOrder.creator.note || '-'}
                </Text>
            </HStack>

            <Box h={'20rem'}>
                <Tables<ProductDelivery>
                    columns={[
                        {
                            header: 'Produk',
                            render: (it) => <StackAvatar imageUrl={it.imageUrl} name={it.name} />,
                        },
                        {
                            header: 'Brand',
                            render: (it) => <Text>{it.brand}</Text>,
                            width: '100px',
                        },

                        {
                            header: 'Ukuran',
                            render: (it) => <Text>{it.size}</Text>,
                            width: '100px',
                        },
                        {
                            header: 'Jumlah Pesanan',
                            render: (it) => <Text>{it.purcaseQty}</Text>,
                            width: '100px',
                        },
                        {
                            header: 'Stok',
                            render: (it) => {
                                if (loadingGetProduct) {
                                    return <Skeleton height="20px" />
                                }

                                return <Text>{qtyProdct ? qtyProdct[branch?.id + '-' + it.id] : 0}</Text>
                            },
                            width: '100px',
                        },
                        {
                            header: 'Jumlah Diantar',
                            render: (it) => (
                                <Input
                                    pr="5rem"
                                    type="number"
                                    value={it.deliveryQty}
                                    onChange={(e) => {
                                        const qty = Number(e.target.value)
                                        onSetDeliveryQty({
                                            productId: it.id,
                                            qty,
                                            currentQty: qtyProdct ? qtyProdct[branch?.id + '-' + it.id] : 0,
                                        })
                                    }}
                                />
                            ),
                            width: '100px',
                        },
                        {
                            header: 'Gudang',
                            render: (it) => (
                                <Select
                                    isClearable={true}
                                    options={branch?.warehouse.map((v) => {
                                        const label = v.isDefault ? '- Gudang Utama' : ''
                                        return {
                                            value: JSON.stringify(v),
                                            label: `${v.name} ${label}`,
                                        }
                                    })}
                                    placeholder="Pilih Gudang"
                                    onChange={(e) => {
                                        if (e) {
                                            onSetWarehouseOnProduct(it.id, JSON.parse(e.value))
                                            setQtyReq({
                                                productId: branch?.id + '-' + it.id,
                                                warehouseId: JSON.parse(e.value).id,
                                            })
                                        } else {
                                            const find = dataProduct.map((v) => {
                                                if (v.id === it.id) {
                                                    return {
                                                        ...v,
                                                        deliveryQty: 0,
                                                        warehouse: null,
                                                    }
                                                }
                                                return v
                                            })
                                            setDataProduct(find)
                                        }
                                    }}
                                    menuPortalTarget={document.body}
                                    styles={{
                                        menuPortal: (base) => ({ ...base, zIndex: 9999 }),
                                    }}
                                />
                            ),
                        },
                    ]}
                    data={dataProduct}
                    pageH="100%"
                />
            </Box>
            <Buttons my={'10px'} label="Buat Pengantaran" onClick={onCreatePackingList} isLoading={createPackingList.isLoading} />
        </Modals>
    )
}

const SelectrCourier: React.FC<ICreateDelivery> = ({ data, isOpen, setOpen, branch }) => {
    const setClose = () => setOpen(false)
    const admin = store.useStore((i) => i.admin)
    const [isLoadingInternal, setLoadingInternal] = React.useState(false)
    const [isLoadingExternal, setLoadingExternal] = React.useState(false)
    const { data: courier } = employeeService.useGetEmployee({
        query: `${Eroles.COURIER},${admin?.location?.id ?? ''}`,
    })
    const { setCourierInternal, setCourierExternal } = deliveryService.useDelivery()
    const [couriers, setCouriers] = React.useState<Courier>()

    const onSetCourier = async () => {
        if (!couriers) return
        setLoadingInternal(true)
        await setCourierInternal.mutateAsync(
            {
                id: couriers.id,
                imageUrl: couriers.imageUrl,
                name: couriers.name,
                phone: couriers.phone,
                deliveryId: data.id,
            },
            {
                onSuccess: () => {
                    setLoadingInternal(false)
                    setOpen(false)
                },
                onError: () => {
                    setLoadingInternal(false)
                },
            }
        )
    }

    const onSetCourierExternal = async () => {
        if (!branch) return
        const defaultWarehouse = branch.warehouse.find((i) => i.isDefault)
        if (!defaultWarehouse) return
        setLoadingExternal(true)
        const customer = await getCustomerApiInfo().findCustomerById(data.customer.id)
        await setCourierExternal.mutateAsync(
            {
                customer: {
                    id: data.customer.id,
                    addressName: data.customer.addressName,
                    addressLngLat: data.customer.addressLngLat,
                    name: data.customer.name,
                    phone: data.customer.phone,
                    picName: customer.business?.pic?.name || data.customer.name,
                    picPhone: customer.business?.pic?.phone || data.customer.phone,
                },
                id: data.id,
                customerPicName: customer.business?.pic?.name || data.customer.name,
                customerPicPhone: customer.business?.pic?.phone || data.customer.phone,
                customerAddressName: data.customer.addressName,
                customerAddressLng: data.customer.addressLngLat[0],
                customerAddressLat: data.customer.addressLngLat[1],
                warehousePicName: defaultWarehouse.name,
                warehousePicPhone: defaultWarehouse.phone,
                warehouseAddressName: defaultWarehouse.address.name,
                warehouseAddressLng: defaultWarehouse.address.lngLat[0],
                warehouseAddressLat: defaultWarehouse.address.lngLat[1],
                item: data.product.map((v) => `${v.name} - Ukuran ${v.size}`).join(','),
            },
            {
                onSuccess: () => {
                    setOpen(false)
                    setLoadingExternal(false)
                },
                onError: () => {
                    setLoadingExternal(false)
                },
            }
        )
    }

    return (
        <Modals isOpen={isOpen} setOpen={setClose} title="Pilih Kurir" size="3xl" scrlBehavior="outside">
            <Box mb={'10px'}>
                <Text fontWeight={'semibold'} fontSize={'sm'}>
                    Cari Kurir
                </Text>
                <Select
                    options={courier?.items.map((i) => ({
                        value: JSON.stringify(i),
                        label: i.name,
                    }))}
                    onChange={(e) => {
                        if (e) {
                            setCouriers(JSON.parse(e.value))
                        }
                    }}
                    placeholder="Ketik nama kurir .."
                />
            </Box>
            <HStack>
                {data.courierType === CourierType.EXTERNAL && (
                    <>
                        <Buttons isLoading={isLoadingInternal} label="Pilih Kurir Internal" w={'10rem'} onClick={onSetCourier} />
                        <Buttons isLoading={isLoadingExternal} label="Pilih Kurir External" w={'10rem'} onClick={onSetCourierExternal} />
                    </>
                )}
                {data.courierType === CourierType.INTERNAL && (
                    <Buttons isLoading={isLoadingInternal} label="Pilih Kurir Internal" w={'10rem'} onClick={onSetCourier} />
                )}
            </HStack>
        </Modals>
    )
}

const DetailDelivery: React.FC<IDelivery> = ({ data, isOpen, setOpen, branch, dataOrder }) => {
    const setClose = () => setOpen(false)
    const [changeCourier, setChangeCourier] = React.useState(false)
    const [idWarehouseRestock, setidWarehouseRestock] = React.useState('')
    const { data: dataDelivery, error, isLoading } = deliveryService.useGetDeliveryById(data.id)
    const [dataProduct, setDataProduct] = React.useState<ProductDelivery[]>([])
    const { setUpdateDelivertQty, setRestockPackingList } = deliveryService.useDelivery()
    const [brokenQty, setBrokenQty] = React.useState<{ [key: string]: number }>({})
    const checkIsProductRestock = () => {
        if (dataDelivery.status !== StatusDelivery.RESTOCK) return dataDelivery.product
        return dataDelivery.product.filter((v) => v.status === StatusDelivery.RESTOCK)
    }

    React.useEffect(() => {
        if (dataDelivery) {
            const cProduct = checkIsProductRestock()
            setDataProduct(cProduct)
        }
    }, [isLoading])

    const onUpdateQty = async (req: { qty: number; productId: string }) => {
        void setUpdateDelivertQty.mutateAsync({
            deliveryQty: req.qty,
            id: data.id,
            productId: req.productId,
        })
    }

    const onRestock = async (req: { warehouseId: string }) => {
        if (!dataDelivery || data.status !== StatusDelivery.RESTOCK) return
        setidWarehouseRestock(req.warehouseId)

        await setRestockPackingList.mutateAsync({
            id: data.id,
            warehouseId: req.warehouseId,
            branchId: data.branchId,
        })
        setidWarehouseRestock('')
        setClose()
    }

    const columnDelivery: Types.Columns<ProductDelivery>[] = [
        {
            header: 'Produk',
            render: (it) => <StackAvatar imageUrl={it.imageUrl} name={it.name} />,
        },
        {
            header: 'Brand',
            render: (it) => <Text>{it.brand}</Text>,
        },
        {
            header: 'Kategori',
            render: (it) => <Text>{it.category}</Text>,
        },

        {
            header: 'Ukuran',
            render: (it) => <Text>{it.size}</Text>,
        },

        {
            header: 'Status',
            render: (it) => <Text>{entity.statusDeliver(it.status)}</Text>,
        },

        {
            header: `${data.status !== StatusDelivery.RESTOCK ? 'Jumlah Diantar' : 'Jumlah Retur'}`,
            render: (it) => {
                if (data.status === StatusDelivery.COMPLETE) {
                    return <Input isReadOnly pr="5rem" type="number" defaultValue={it.deliveryQty} />
                }
                if (data.status !== StatusDelivery.RESTOCK) {
                    return (
                        <StackInputBtn
                            initQty={it.deliveryQty}
                            isLoading={setUpdateDelivertQty.isLoading}
                            onClick={(q) => {
                                onUpdateQty({
                                    productId: it.id,
                                    qty: q,
                                })
                            }}
                        />
                    )
                }

                return (
                    <Input
                        isReadOnly
                        pr="5rem"
                        type="number"
                        defaultValue={it.brokenQty}
                        onChange={(e) => {
                            const currentBroken = it.deliveryQty
                            const qty = Number(e.target.value)
                            if (qty > currentBroken) return
                            setBrokenQty({
                                ...brokenQty,
                                [it.id]: qty,
                            })
                        }}
                    />
                )
            },
        },
        {
            header: 'Aksi',
            render: (it) => (
                <Buttons
                    label="Restock"
                    isLoading={idWarehouseRestock === it.id && setRestockPackingList.isLoading}
                    isDisabled={data.status !== StatusDelivery.RESTOCK}
                    onClick={() =>
                        onRestock({
                            warehouseId: it.warehouse?.id ?? '',
                        })
                    }
                />
            ),
        },
    ]

    const filterColumns = (): Types.Columns<ProductDelivery, React.ReactNode>[] => {
        if (data.status !== StatusDelivery.RESTOCK) {
            const r = columnDelivery.filter((v) => v.header !== 'Jumlah Diantar' && v.header !== 'Aksi')
            return [
                ...r,
                {
                    header: 'Jumlah Diantar',
                    render: (v) => <Text>{v.deliveryQty}</Text>,
                },
            ]
        }
        return columnDelivery
    }

    return (
        <Modals isOpen={isOpen} setOpen={setClose} title="Detail Pengantaran" size="6xl">
            {error && <PText label={error} />}
            {!error && (
                <>
                    {isLoading ? (
                        <LoadingForm />
                    ) : (
                        <>
                            {changeCourier && data && (
                                <SelectrCourier
                                    isOpen={changeCourier}
                                    setOpen={setChangeCourier}
                                    data={data}
                                    product={data.product}
                                    branch={branch}
                                    dataOrder={dataOrder}
                                />
                            )}
                            <HStack mb={'10px'}>
                                <Text fontSize={'16px'}>Catatan Pelanggan:</Text>
                                <Text fontWeight={'bold'} fontSize={'16px'}>
                                    {dataOrder.creator.note || '-'}
                                </Text>
                            </HStack>
                            <HStack justify={'space-between'}>
                                <VStack align={'start'}>
                                    <HStack>
                                        <Avatar size={'lg'} src={data.courier?.imageUrl} name={data.courier?.name} />
                                        <Box fontSize={'sm'}>
                                            <Text fontWeight={'bold'}>
                                                {data.courier?.name || '-'}
                                                <Badge ml="2" colorScheme="green">
                                                    {entity.statusTypeCourier(data.courierType)}
                                                </Badge>
                                            </Text>
                                            <Text fontWeight={'bold'}>{data.courier?.phone || '-'}</Text>
                                        </Box>
                                    </HStack>
                                    {data.note && (
                                        <Box w={'full'}>
                                            <Text fontSize={'sm'}>Catatan</Text>
                                            <Text fontWeight={'500'} fontSize={'md'}>
                                                {data.note}
                                            </Text>
                                        </Box>
                                    )}
                                </VStack>

                                {dataDelivery.status === StatusDelivery.PICKED_UP && dataDelivery.courierType === CourierType.INTERNAL && (
                                    <Buttons w={'150px'} label="Ganti Kurir" onClick={() => setChangeCourier(true)} />
                                )}
                            </HStack>
                            <Divider my={2} />
                            <Box h={'20rem'}>
                                <Tables<ProductDelivery> columns={filterColumns()} data={dataProduct} pageH="100%" />
                            </Box>
                        </>
                    )}
                </>
            )}
        </Modals>
    )
}

const Orders: React.FC<{ status: StatusDelivery }> = ({ status }) => {
    const admin = store.useStore((i) => i.admin)
    const navigate = useNavigate()
    const { column, isOpen, selectData, setOpen } = columnsDelivery({ status })
    const { data, error, isLoading, onSetQuery, page } = deliveryService.useGetDelivery()
    const { data: dataOrder } = orderService.useGetOrderById(`${selectData?.orderId}`)
    const { data: branch } = branchService.useGetBranchId(String(admin?.location.id))

    React.useEffect(() => {
        navigate({ pathname: '/order', search: `status=${status}` })
        onSetQuery({
            page: page,
            branchId: `${admin?.location.id}`,
            status,
        })
    }, [data])

    const setPages = (v: number) => {
        onSetQuery({
            page: Number(page) + v,
            branchId: `${admin?.location.id}`,
            status,
        })
    }

    const canShowDetail = () => {
        if (status === StatusDelivery.PICKED_UP) return true
        if (status === StatusDelivery.DELIVER) return true
        if (status === StatusDelivery.RESTOCK) return true
        if (status === StatusDelivery.WAITING_DELIVER) return true
        if (status === StatusDelivery.COMPLETE) return true
        return false
    }

    return (
        <Box>
            {isOpen && selectData && dataOrder && canShowDetail() && (
                <DetailDelivery dataOrder={dataOrder} data={selectData} isOpen={isOpen} setOpen={setOpen} branch={branch} />
            )}
            {isOpen && status === StatusDelivery.CREATE_PACKING_LIST && selectData && dataOrder && (
                <CreateDelivery
                    dataOrder={dataOrder}
                    isOpen={isOpen}
                    setOpen={setOpen}
                    product={selectData?.product || []}
                    branch={branch}
                    data={selectData}
                />
            )}
            {isOpen && status === StatusDelivery.ADD_COURIER && selectData && dataOrder && (
                <SelectrCourier
                    dataOrder={dataOrder}
                    isOpen={isOpen}
                    setOpen={setOpen}
                    product={selectData?.product || []}
                    branch={branch}
                    data={selectData}
                />
            )}

            {error ? (
                <PText label={error} />
            ) : (
                <>
                    <Tables columns={column} isLoading={isLoading} data={!data ? [] : data?.items} usePaging={true} useTab={true} />
                    <PagingButton
                        disableNext={data?.next ? true : false}
                        page={Number(page)}
                        disablePrev={data?.back ? true : false}
                        nextPage={() => {
                            setPages(1)
                        }}
                        prevPage={() => {
                            setPages(-1)
                        }}
                    />
                </>
            )}
        </Box>
    )
}

const OrderPages = () => {
    const listNavigation = ['DAFTAR PESANAN', 'PILIH KURIR', 'PENJEMPUTAN', 'DIMUAT', 'PENGANTARAN', 'RETUR', 'SELESAI']
    const [query] = useSearchParams()

    const idxx = (): number => {
        const status = query.get('status')
        if (status === TypeReqDelivery.CREATE_PACKING_LIST) {
            return 0
        }
        if (status === TypeReqDelivery.ADD_COURIER) {
            return 1
        }
        if (status === TypeReqDelivery.PICKED_UP) {
            return 2
        }
        if (status === TypeReqDelivery.WAITING_DELIVER) {
            return 3
        }
        if (status === TypeReqDelivery.DELIVER) {
            return 4
        }
        if (status === TypeReqDelivery.RESTOCK) {
            return 5
        }
        if (status === TypeReqDelivery.COMPLETE) {
            return 6
        }
        return 0
    }

    return (
        <Wrap>
            <TabsComponent TabList={listNavigation} defaultIndex={idxx()}>
                <TabPanel px={0}>
                    <Orders status={StatusDelivery.CREATE_PACKING_LIST} />
                </TabPanel>
                <TabPanel px={0}>
                    <Orders status={StatusDelivery.ADD_COURIER} />
                </TabPanel>
                <TabPanel px={0}>
                    <Orders status={StatusDelivery.PICKED_UP} />
                </TabPanel>
                <TabPanel px={0}>
                    <Orders status={StatusDelivery.WAITING_DELIVER} />
                </TabPanel>
                <TabPanel px={0}>
                    <Orders status={StatusDelivery.DELIVER} />
                </TabPanel>
                <TabPanel px={0}>
                    <Orders status={StatusDelivery.RESTOCK} />
                </TabPanel>
                <TabPanel px={0}>
                    <Orders status={StatusDelivery.COMPLETE} />
                </TabPanel>
            </TabsComponent>
        </Wrap>
    )
}
export default OrderPages

const columnsDelivery = (req: { status: StatusDelivery }) => {
    const [selectData, setSelectData] = React.useState<Delivery>()
    const [isOpenLive, setOpenLive] = React.useState(false)
    const [isOpen, setOpen] = React.useState(false)
    const [isOpenDetail, setOpenDetail] = React.useState(false)

    let column: Types.Columns<Delivery>[] = [
        {
            header: 'ID Pengantaran',
            render: (i) => <Text>{i.id}</Text>,
        },
        {
            header: 'Pelanggan',
            render: (i) => (
                <Box>
                    <Text>{i.customer.name}</Text>
                    <Text>{i.customer.phone}</Text>
                </Box>
            ),
        },
        {
            header: 'Jenis Kurir',
            render: (i) => <Text>{entity.statusTypeCourier(i.courierType)}</Text>,
        },
        {
            header: 'Cabang',
            render: (i) => <Text>{i.branchName}</Text>,
        },
        {
            header: 'Status',
            render: (i) => <Text>{entity.statusDeliver(i.status)}</Text>,
        },

        {
            header: 'Tanggal Dibuat',
            render: (i) => <Text>{Shared.FormatDateToString(i.createdAt)}</Text>,
        },
        {
            header: 'Aksi',
            render: (v) => (
                <HStack>
                    <ButtonTooltip
                        label={'Detail'}
                        icon={<Icons.IconDetails color={'gray'} />}
                        onClick={() => {
                            setOpen(true)
                            setOpenDetail(true)
                            setSelectData(v)
                        }}
                    />
                    {v.status === StatusDelivery.DELIVER && (
                        <ButtonTooltip
                            label={'Tracking'}
                            icon={<Icons.IconDelivery color={'gray'} />}
                            onClick={() => {
                                if (v.courierType === CourierType.INTERNAL) {
                                    open(`/tracking-delivery/${v.id}`)
                                }
                                if (v.courierType === CourierType.EXTERNAL && v.url) {
                                    open(`${v.url}`)
                                }
                            }}
                        />
                    )}
                </HStack>
            ),
        },
    ]

    if (req.status === StatusDelivery.COMPLETE) {
        column = column.filter((i) => i.header !== 'Status')
    }

    return {
        column,
        selectData,
        isOpenLive,
        setOpenLive,
        isOpen,
        setOpen,
        isOpenDetail,
        setOpenDetail,
    }
}
