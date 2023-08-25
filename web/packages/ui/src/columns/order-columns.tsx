import { Types, entity } from 'ui'
import { StackAvatar } from '../stack-avatar'
import { FormatDateToString, formatRupiah, splitText } from '../utils/shared'
import { ListItem, UnorderedList, Text } from '@chakra-ui/react'
import { Order } from 'apis'

type Exclude =
    | 'cancel'
    | 'branchName'
    | 'code'
    | 'invoicePaid'
    | 'poFilePath'
    | 'priceName'
    | 'regionName'
    | 'updatedAt'
    | 'regionId'
    | 'priceId'
    | 'branchId'
    | 'invoiceId'
    | 'deliveryId'

type Keys = keyof Omit<Order, Exclude>
type ColumnsTypes = {
    [key in Keys]: Types.Columns<Order>
}

export const columnsOrder: ColumnsTypes = {
    id: {
        header: 'ID Pesanan',
        render: (i) => <Text>{i.id}</Text>,
    },
    customer: {
        header: 'Pelanggan',
        render: (i) => (
            <StackAvatar
                imageUrl={i.customer.imageUrl}
                name={i.customer.name}
            />
        ),
    },
    deliveryPrice: {
        header: 'Ongkos Kirim',
        render: (i) => <Text>{formatRupiah(`${i.deliveryPrice}`)}</Text>,
    },
    totalPrice: {
        header: 'Total Pembayaran',
        render: (i) => <Text>{formatRupiah(`${i.totalPrice}`)}</Text>,
    },
    productPrice: {
        header: 'Total Produk',
        render: (i) => <Text>{formatRupiah(`${i.productPrice}`)}</Text>,
    },
    creator: {
        header: 'Dibuat Oleh',
        render: (i) => (
            <StackAvatar imageUrl={i.creator.imageUrl} name={i.creator.name} />
        ),
    },
    status: {
        header: 'Status',
        render: (i) => <>{entity.statusOrder(i.status)}</>,
    },
    product: {
        header: 'Produk',
        render: (i) => (
            <UnorderedList>
                {i.product.map((item, index) => (
                    <ListItem key={index}>{splitText(item.name, 20)}</ListItem>
                ))}
            </UnorderedList>
        ),
    },
    createdAt: {
        header: 'Tanggal Dibuat',
        render: (i) => <Text>{FormatDateToString(i.createdAt)}</Text>,
    },
}
