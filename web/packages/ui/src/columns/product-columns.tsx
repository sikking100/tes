import { Text } from '@chakra-ui/layout'
import { Types, Shared, entity } from 'ui'
import { ProductTypes } from 'apis'
import { StackAvatar } from '../stack-avatar'
import { splitText } from '../utils/shared'
// import { entity } from '../utils'

type Exclude =
    | 'imageUrl'
    | 'brand_'
    | 'category_'
    | 'team_'
    | 'branchId'
    | 'isVisible'
    | 'priceList'
    | 'price'
    | 'warehouse'
    | 'salesName'
    | 'salesId'

type TProduct = ProductTypes.Product & {
    team: string
    isCheck?: boolean
    qty?: number
    nQty?: number
}

type ProductTypes = Omit<TProduct, Exclude>
type Keys = keyof ProductTypes
type ColumnsTypes = {
    [key in Keys]: Types.Columns<TProduct>
}

export const columnsProduct: ColumnsTypes = {
    isCheck: {
        header: '',
        render: () => <p></p>,
    },
    qty: {
        header: '',
        render: () => <p></p>,
    },
    nQty: {
        header: '',
        render: () => <p></p>,
    },
    team: {
        header: 'Tim',
        render: (v) => <Text>{entity.team(String(v.category.team))}</Text>,
        width: '200px',
    },
    productId: {
        header: 'ID',
        render: (v) => <Text>{v.productId}</Text>,
        width: '200px',
    },
    id: {
        header: 'ID',
        render: (v) => <Text>{v.id}</Text>,
        width: '200px',
    },
    name: {
        header: 'Nama',
        render: (v) => (
            <StackAvatar imageUrl={v.imageUrl} name={splitText(v.name, 15)} />
        ),
        width: '200px',
    },
    orderCount: {
        header: 'Jumlah Terjual',
        render: (v) => <Text>{v.orderCount}</Text>,
        width: '200px',
    },

    size: {
        header: 'Ukuran',
        render: (v) => <Text>{v.size}</Text>,
        width: '200px',
    },
    point: {
        header: 'Poin',
        render: (v) => <Text>{v.point}</Text>,
        width: '200px',
    },
    brand: {
        header: 'Brand',
        render: (v) => (
            <StackAvatar
                imageUrl={v.brand.imageUrl}
                name={splitText(v.brand.name, 15)}
            />
        ),
        width: '200px',
    },
    category: {
        header: 'Kategori',
        render: (v) => <Text>{v.category.name}</Text>,
        width: '200px',
    },
    description: {
        header: 'Deskripsi',
        render: (v) => <Text>{v.description}</Text>,
        width: '200px',
    },

    createdAt: {
        header: 'Tanggal Dibuat',
        render: (v) => <Text>{Shared.FormatDateToString(v.createdAt)}</Text>,
    },
    updatedAt: {
        header: 'Tanggal Diperbarui',
        render: (v) => <Text>{Shared.FormatDateToString(v.updatedAt)}</Text>,
    },
}
