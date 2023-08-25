import React from 'react'
import { Box, Text, VStack, HStack, VisuallyHidden } from '@chakra-ui/react'
import { Employee, ProductDelivery, SelectsTypes, StatusDelivery } from 'apis'
import { deliveryService } from 'hooks'
import Select from 'react-select'
import { ButtonTooltip, Icons, Modals, PText, PagingButton, Shared, StackAvatar, Tables, Types, entity } from 'ui'
import { useReactToPrint } from 'react-to-print'

interface Props {
    isOpen: boolean
    setOpen: (v: boolean) => void
    data: Employee
}

type TProduct = ProductDelivery & {
    idDelivery: string
    createdAt: string
}

const Deliverys: React.FC<{ status: StatusDelivery; data: Employee }> = ({ status, data }) => {
    const [productDelivery, setProductDelivery] = React.useState<TProduct[]>([])
    const { data: delivery, error, isLoading, onSetQuery, page } = deliveryService.useGetDelivery()
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
            <HStack mt="5px">
                <VStack align={'start'} spacing={0}>
                    <Text fontWeight={'normal'}>{data.name}</Text>
                    <Text fontSize={'sm'} fontWeight={'normal'}>
                        {data.phone}
                    </Text>
                </VStack>
            </HStack>
            <Tables<ProductDelivery>
                columns={[
                    {
                        header: 'Gudang',
                        render: (it) => <Text fontWeight={'normal'}>{it.warehouse?.name || '-'}</Text>,
                        width: '200px',
                    },
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
                data={productDelivery}
                pageH="100%"
            />
        </Box>
    )

    React.useEffect(() => {
        if (data) {
            onSetQuery({
                branchId: data.location.id,
                courierId: data.id,
                status,
                limit: 10,
            })
        }
        if (delivery) {
            const dataProds: TProduct[] = []
            delivery.items.map((v) => {
                v.product.forEach((p) => {
                    dataProds.push({
                        idDelivery: v.id,
                        id: p.id,
                        brand: p.brand,
                        brokenQty: p.brokenQty,
                        category: p.category,
                        deliveryQty: p.deliveryQty,
                        imageUrl: p.imageUrl,
                        name: p.name,
                        purcaseQty: p.purcaseQty,
                        reciveQty: p.reciveQty,
                        size: p.size,
                        status: p.status,
                        warehouse: p.warehouse,
                        createdAt: v.createdAt,
                    })
                })
            })
            setProductDelivery(dataProds)
        }
    }, [data, status, delivery])

    const columns: Types.Columns<TProduct>[] = [
        {
            header: 'ID Pengantaran',
            render: (it) => <Text>{it.idDelivery}</Text>,
        },
        {
            header: 'Gudang',
            render: (it) => <Text>{it.warehouse?.name || '-'}</Text>,
        },
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
            header: 'Jumlah Diantar',
            render: (it) => <Text>{it.deliveryQty}</Text>,
        },
        {
            header: 'Tanggal Dibuat',
            render: (it) => <Text>{Shared.FormatDateToString(it.createdAt)}</Text>,
        },
    ]

    return (
        <Box>
            <VisuallyHidden>
                <PrintPackingList />
            </VisuallyHidden>
            {status === StatusDelivery.WAITING_DELIVER && (
                <Box>
                    <ButtonTooltip icon={<Icons.IconPrint />} label="Print" bg="red.400" onClick={handlePrint} isLoading={onLoadPrint} />
                </Box>
            )}
            <Box h={'30rem'}>
                {error ? (
                    <PText label={error} />
                ) : (
                    <Box>
                        <Tables<ProductDelivery> columns={columns} data={productDelivery} pageH="100%" isLoading={isLoading} />
                        <Box mt="5px">
                            <PagingButton
                                page={Number(page)}
                                nextPage={() => onSetQuery({ page: Number(page) + 1, branchId: data.location.id, status })}
                                prevPage={() => onSetQuery({ page: Number(page) - 1, branchId: data.location.id, status })}
                                disableNext={delivery?.next === null}
                            />
                        </Box>
                    </Box>
                )}
            </Box>
        </Box>
    )
}

const DetailDelivery: React.FC<Props> = ({ data, isOpen, setOpen }) => {
    const setClose = () => setOpen(false)
    const [statusDeliver, setStatusDeliver] = React.useState<StatusDelivery>(StatusDelivery.PICKED_UP)

    const statusDelivery: SelectsTypes[] = [
        {
            value: `${StatusDelivery.PICKED_UP}`,
            label: 'Penjemputan',
        },
        {
            value: `${StatusDelivery.WAITING_DELIVER}`,
            label: 'Dimuat',
        },
        {
            value: `${StatusDelivery.DELIVER}`,
            label: 'Pengantaran',
        },
        {
            value: `${StatusDelivery.RESTOCK}`,
            label: 'Retur',
        },
        {
            value: `${StatusDelivery.COMPLETE}`,
            label: 'Selesai',
        },
    ]

    return (
        <Modals isOpen={isOpen} setOpen={setClose} title="Detail Pengantaran" size="6xl">
            <Box mb="10px">
                <Select
                    options={statusDelivery}
                    defaultValue={statusDelivery[0]}
                    placeholder="Pilih status"
                    onChange={(e) => {
                        if (!e) return
                        const val = parseInt(e.value)
                        setStatusDeliver(val)
                    }}
                    menuPortalTarget={document.body}
                    styles={{ menuPortal: (base) => ({ ...base, zIndex: 9999 }) }}
                />
            </Box>

            <Deliverys data={data} status={statusDeliver} />
        </Modals>
    )
}

export default DetailDelivery
