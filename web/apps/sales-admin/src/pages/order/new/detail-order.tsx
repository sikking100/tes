import React from 'react'
import { deliveryService, invoiceService, orderService, useDownloadImage } from 'hooks'
import { Shared, Tables, Types, StackAvatar, Modals, PText, LoadingForm, entity, Timelines } from 'ui'
import {
    Accordion,
    AccordionButton,
    AccordionIcon,
    AccordionItem,
    AccordionPanel,
    Box,
    HStack,
    Link,
    SimpleGrid,
    Text,
} from '@chakra-ui/react'
import { CourierType, ProductOrder, StatusDelivery, StatusInvoice } from 'apis'
import { TextTitle } from './card-detail-info-order'

interface Props {
    isOpen: boolean
    setOpen: (v: boolean) => void
    idOrder: string
    deliveryId: string
}

const DetailOrder: React.FC<Props> = ({ isOpen, setOpen, idOrder, deliveryId }) => {
    const { data, error, isLoading } = orderService.useGetOrderById(idOrder)
    const { data: invoice, error: invoiceError, isLoading: invoiceLoading } = invoiceService.useGetInvoiceById(`${data?.invoiceId}`)
    const { data: delivery, error: deliveryError, isLoading: deliveryLoading } = deliveryService.useGetDeliveryOrderId(`${idOrder}`)
    const { data: dDelivery, isLoading: dDeliveryLoading } = deliveryService.useGetDeliveryById(deliveryId)

    const columnsProduct = columnsListProduct()
    const [urlPo, setUrlPo] = React.useState('')

    React.useEffect(() => {
        if (data) {
            Promise.all([useDownloadImage(data?.poFilePath)]).then((i) => {
                setUrlPo(i[0])
            })
        }
    }, [isLoading])

    const onClose = () => setOpen(false)

    const isLoadings = (): boolean => {
        return isLoading || invoiceLoading || deliveryLoading || dDeliveryLoading
    }

    const isErrors = (): string => {
        return error || invoiceError || deliveryError || ''
    }

    return (
        <Modals isOpen={isOpen} setOpen={onClose} size="6xl" title="Detail Pesanan">
            {isErrors() ? (
                <PText label={isErrors()} />
            ) : isLoadings() ? (
                <LoadingForm />
            ) : (
                <Box>
                    <Box rounded={'lg'} shadow={'none'} fontSize={'sm'}>
                        {urlPo ? (
                            <Link
                                isExternal={true}
                                href={urlPo}
                                fontWeight={'bold'}
                                fontSize={'16px'}
                                mb={'10px'}
                                textDecoration={'underline'}
                                cursor={'pointer'}
                            >
                                Lihat PO
                            </Link>
                        ) : (
                            <Text fontWeight={'bold'} fontSize={'16px'} mb={'10px'} textDecoration={'underline'} cursor={'pointer'}>
                                Lihat PO
                            </Text>
                        )}

                        {/*  */}
                        <HStack mb={'10px'}>
                            <Text fontSize={'16px'}>Catatan:</Text>
                            <Text fontWeight={'bold'} fontSize={'16px'}>
                                {data.customer.note || '-'}
                            </Text>
                        </HStack>
                        {/*  */}
                        <Accordion defaultIndex={[0]} allowMultiple>
                            {/* INVOICE */}
                            <AccordionItem p={0}>
                                <AccordionButton py={2} px={0}>
                                    <Box as="span" flex="1" textAlign="left">
                                        Invoice
                                    </Box>
                                    <AccordionIcon />
                                </AccordionButton>
                                <AccordionPanel px={0}>
                                    <SimpleGrid columns={2} mt={2} gap={1}>
                                        <TextTitle title="ID Invoice" val={<Text>{invoice?.id}</Text>} />
                                        <TextTitle title="Jumlah Tagihan" val={<Text>{Shared.formatRupiah(`${invoice.price}`)}</Text>} />
                                        <TextTitle
                                            title="Metode Pembayaran"
                                            val={<Text>{entity.paymentMethod(Number(invoice?.paymentMethod))}</Text>}
                                        />
                                        <TextTitle title="Status" val={<Text>{entity.statusInvoice(invoice.status)}</Text>} />
                                        <TextTitle
                                            title="Tanggal Pembayaran"
                                            val={
                                                <Text>
                                                    {invoice.status === StatusInvoice.PAID
                                                        ? `${Shared.FormatDateToString(invoice.paidAt)}`
                                                        : '-'}
                                                </Text>
                                            }
                                        />
                                    </SimpleGrid>
                                </AccordionPanel>
                            </AccordionItem>
                            {/* PRODUK */}
                            <AccordionItem p={0}>
                                <AccordionButton py={2} px={0}>
                                    <Box as="span" flex="1" textAlign="left">
                                        Detail Produk
                                    </Box>
                                    <AccordionIcon />
                                </AccordionButton>
                                <AccordionPanel px={0}>
                                    <Box>
                                        <Tables
                                            isLoading={isLoading}
                                            columns={columnsProduct}
                                            data={isLoading ? [] : data.product}
                                            pageH="100%"
                                        />
                                    </Box>
                                    {/* CourierType */}
                                    <Box experimental_spaceY={1}>
                                        <HStack justify={'space-between'} fontWeight={'bold'}>
                                            <Text>Ongkos Kirim</Text>
                                            <Text>{Shared.formatRupiah(`${data.deliveryPrice}`)}</Text>
                                        </HStack>
                                        <HStack justify={'space-between'} fontWeight={'bold'}>
                                            <Text>Total Pembayaran</Text>
                                            <Text>{Shared.formatRupiah(`${data.totalPrice + data.deliveryPrice}`)}</Text>
                                        </HStack>
                                    </Box>
                                </AccordionPanel>
                            </AccordionItem>
                            {/* DELIVERY */}
                            <AccordionItem>
                                <AccordionButton py={2} px={0}>
                                    <Box as="span" flex="1" textAlign="left">
                                        Pengantaran
                                    </Box>
                                    <AccordionIcon />
                                </AccordionButton>
                                <AccordionPanel px={0}>
                                    <Text fontWeight={'bold'} fontSize={'16px'}>
                                        {dDelivery.courierType === CourierType.EXTERNAL ? 'External' : 'Internal'}
                                    </Text>

                                    {dDelivery.url && dDelivery.courierType === CourierType.EXTERNAL && (
                                        <Box mb="20px">
                                            <Link
                                                isExternal={true}
                                                href={dDelivery.url}
                                                fontWeight={'bold'}
                                                fontSize={'16px'}
                                                textDecoration={'underline'}
                                            >
                                                Tracking Pengantaran GOSEND
                                            </Link>
                                        </Box>
                                    )}
                                    {dDelivery.courierType === CourierType.INTERNAL && dDelivery.status === StatusDelivery.DELIVER && (
                                        <Box mb="20px">
                                            <Link
                                                isExternal={true}
                                                href={`/delivery-tracking/${dDelivery.id}`}
                                                fontWeight={'bold'}
                                                fontSize={'16px'}
                                                textDecoration={'underline'}
                                            >
                                                Tracking Pengantaran
                                            </Link>
                                        </Box>
                                    )}
                                    {dDelivery.courierType === CourierType.INTERNAL && <>{delivery && <Timelines data={delivery} />}</>}
                                </AccordionPanel>
                            </AccordionItem>
                        </Accordion>
                    </Box>
                </Box>
            )}
        </Modals>
    )
}

const columnsListProduct = () => {
    const column: Types.Columns<ProductOrder>[] = [
        {
            header: 'Nama Produk',
            render: (v) => <StackAvatar imageUrl={v.imageUrl} name={v.name} />,
        },
        {
            header: 'Harga',
            render: (v) => <Text>{Shared.formatRupiah(`${v.unitPrice}`)}</Text>,
        },
        {
            header: 'Jumlah',
            render: (v) => <Text>{v.qty}</Text>,
        },
        {
            header: 'Total',
            render: (v) => <Text>{Shared.formatRupiah(`${v.unitPrice * v.qty}`)}</Text>,
        },
        {
            header: 'Diskon',
            render: (v) => <Text>{Shared.formatRupiah(`${v.discount}`)}</Text>,
        },
        {
            header: 'Subtotal',
            render: (v) => {
                return <Text>{Shared.formatRupiah(`${v.totalPrice}`)}</Text>
            },
        },
    ]

    return column
}

export default DetailOrder
