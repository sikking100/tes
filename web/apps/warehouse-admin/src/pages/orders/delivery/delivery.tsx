import React from 'react'
import { useNavigate, useSearchParams } from 'react-router-dom'
import { ButtonTooltip, Icons, LoadingForm, Modals, PText, Root, StackAvatar, Tables, Types } from 'ui'
import Select from 'react-select'
import { Avatar, Box, Divider, HStack, Text, VStack, VisuallyHidden } from '@chakra-ui/react'
import { dataListOrder } from '~/navigation'
import { PackingListWarehousue, ProductDelivery, StatusDelivery, Warehouse } from 'apis'
import { store, deliveryService, branchService } from 'hooks'
import { useReactToPrint } from 'react-to-print'

const Wrap: React.FC<{ children: React.ReactNode }> = ({ children }) => (
    <Root appName="Warehouse" items={dataListOrder} backUrl={'/'} activeNum={2}>
        {children}
    </Root>
)

interface PropsDetailPackingList {
    data: PackingListWarehousue
    isOpen: boolean
    setOpen: (v: boolean) => void
    warehouse: Warehouse
}

const DetailPackingList: React.FC<PropsDetailPackingList> = ({ data, isOpen, setOpen, warehouse }) => {
    const setClose = () => setOpen(false)

    const ref = React.useRef<HTMLDivElement | null>(null)
    const [onLoadPrint, setOnLoadPrint] = React.useState(false)
    const handlePrint = useReactToPrint({
        content: () => ref.current,
        fonts: [
            {
                weight: '300',
                family: '',
                source: '',
                style: '',
            },
        ],
        bodyClass: 'print-body',
        onBeforePrint: () => setOnLoadPrint(true),
        onAfterPrint: () => setOnLoadPrint(false),
    })

    const PrintPackingList = () => (
        <Box ref={ref}>
            <Box mb="5px">
                <Text>Packing List</Text>
                <Text fontWeight={'normal'}>{warehouse.name}</Text>
            </Box>
            <Divider />
            <HStack mt="5px">
                <VStack align={'start'} spacing={0}>
                    <Text fontWeight={'normal'}>{data.courier.name}</Text>
                    <Text fontSize={'sm'} fontWeight={'normal'}>
                        {data.courier.phone}
                    </Text>
                </VStack>
            </HStack>
            <Tables<ProductDelivery>
                columns={[
                    {
                        header: 'Produk',
                        render: (it) => <Text fontWeight={'normal'}>{it.name}</Text>,
                        width: '200px',
                    },
                    {
                        header: 'Brand',
                        render: (it) => <Text fontWeight={'normal'}>{it.brand}</Text>,
                        width: '200px',
                    },
                    {
                        header: 'Ukuran',
                        render: (it) => <Text fontWeight={'normal'}>{it.size}</Text>,
                        width: '200px',
                    },
                    {
                        header: 'Ukuran',
                        render: (it) => <Text fontWeight={'normal'}>{it.size}</Text>,
                        width: '200px',
                    },
                    {
                        header: 'Jumlah Barang',
                        render: (it) => <Text fontWeight={'normal'}>{it.deliveryQty}</Text>,
                        width: '200px',
                    },
                ]}
                data={data.product}
                pageH="100%"
            />
        </Box>
    )

    return (
        <Modals isOpen={isOpen} setOpen={setClose} title="Detail Packing List" size="6xl">
            <VisuallyHidden>
                <PrintPackingList />
            </VisuallyHidden>
            <>
                <HStack justify={'space-between'}>
                    <HStack>
                        <Avatar src={data.courier.imageUrl} size={'sm'} boxSize={'100px'} rounded={'full'} />
                        <VStack align={'start'} spacing={0}>
                            <Text fontWeight={'semibold'}>{data.courier.name}</Text>
                            <Text fontSize={'sm'} fontWeight={'semibold'}>
                                {data.courier.phone}
                            </Text>
                        </VStack>
                    </HStack>
                    <Box>
                        <ButtonTooltip
                            icon={<Icons.IconPrint />}
                            label="Print"
                            bg="red.400"
                            onClick={handlePrint}
                            isLoading={onLoadPrint}
                        />
                    </Box>
                </HStack>

                <Box minH={'400px'} maxH={'400px'} overflow={'auto'}>
                    <Tables<ProductDelivery>
                        columns={[
                            {
                                header: 'Produk',
                                render: (it) => <StackAvatar imageUrl={it.imageUrl} name={it.name} />,
                                width: '200px',
                            },
                            {
                                header: 'Brand',
                                render: (it) => <Text>{it.brand}</Text>,
                                width: '200px',
                            },
                            {
                                header: 'Ukuran',
                                render: (it) => <Text>{it.size}</Text>,
                                width: '200px',
                            },
                            {
                                header: 'Jumlah Barang',
                                render: (it) => <Text>{it.deliveryQty}</Text>,
                                width: '200px',
                            },
                        ]}
                        data={data.product}
                        pageH="100%"
                    />
                </Box>
            </>
        </Modals>
    )
}

const PagelistDeliveryPacking = () => {
    const admin = store.useStore((i) => i.admin)
    const navigate = useNavigate()
    const [query] = useSearchParams()
    const { column, isOpen, selectData, setOpen } = columns()
    const [warehouse, setWarehouse] = React.useState<Warehouse | null>(null)
    const [loading, setLoading] = React.useState(true)
    const { data: dataBranch } = branchService.useGetBranchId(String(admin?.location.id))
    const { onSetQuery, data, error, isLoading } = deliveryService.useGetPackingListWarehouse()

    React.useEffect(() => {
        onSetQuery({
            branchId: `${admin?.location.id}`,
            status: StatusDelivery.PICKED_UP,
            warehouseId: query.get('warehouse') || warehouse?.id || '',
        })
        setDefaultWarehouse()
    }, [data, warehouse, admin, query.get('warehouse')])

    const setHeight = React.useMemo(() => {
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
            return '60vh'
        }
        return '100%'
    }, [window.screen.availWidth])

    const setDefaultWarehouse = () => {
        if (!dataBranch) return
        const warehouse = query.get('warehouse')
        const find = dataBranch?.warehouse.find((v) => v.id === warehouse)
        if (find) setWarehouse(find)
        else setWarehouse(dataBranch?.warehouse[0])
        setLoading(false)
    }

    return (
        <Wrap>
            {isOpen && selectData && warehouse && (
                <DetailPackingList warehouse={warehouse} data={selectData} isOpen={isOpen} setOpen={setOpen} />
            )}
            {loading ? (
                <LoadingForm />
            ) : (
                <Box w={'24rem'} mb={'1rem'}>
                    <Select
                        options={dataBranch?.warehouse.map((i) => ({
                            value: JSON.stringify(i),
                            label: `${i.name} `,
                        }))}
                        defaultValue={{
                            value: warehouse?.id,
                            label: warehouse?.name,
                        }}
                        placeholder="Pilih Gudang"
                        onChange={(e) => {
                            const parse = JSON.parse(String(e?.value)) as Warehouse
                            setWarehouse(parse)
                            navigate({ pathname: '/delivery-packinglist', search: `warehouse=${parse.id}` })
                        }}
                        menuPortalTarget={document.body}
                        styles={{
                            menuPortal: (base) => ({ ...base, zIndex: 9999 }),
                        }}
                    />
                </Box>
            )}

            <Box bg="white" rounded={'md'} p={'10px'} mb={'10px'}>
                <Text fontWeight={'bold'} fontSize={'xl'}>
                    {warehouse?.name}
                </Text>
                <Text>{warehouse?.phone}</Text>
                <Text>{warehouse?.address.name}</Text>
                <Text>{warehouse?.isDefault}</Text>
            </Box>
            <Box>
                {error ? (
                    <PText label={error} />
                ) : (
                    <>
                        <Tables columns={column} isLoading={isLoading} data={!data ? [] : data} usePaging={true} pageH={setHeight} />
                    </>
                )}
            </Box>
        </Wrap>
    )
}

export default PagelistDeliveryPacking

const columns = () => {
    const [selectData, setSelectData] = React.useState<PackingListWarehousue>()
    const [isOpen, setOpen] = React.useState(false)

    const column: Types.Columns<PackingListWarehousue>[] = [
        {
            header: 'Kurir',
            render: (i) => (
                <HStack>
                    <Avatar rounded={'full'} boxSize={'60px'} src={i.courier.imageUrl} />
                    <VStack align={'start'}>
                        <Text>{i.courier.name}</Text>
                        <Text>{i.courier.phone}</Text>
                    </VStack>
                </HStack>
            ),
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
    }
}
