import { Box, Text, UnorderedList, ListItem } from '@chakra-ui/react'
import { Types, Shared, entity, StackAvatar } from 'ui'
import { ProductTypes } from 'apis'

type QtyHistoryColumns = {} & ProductTypes.HistoryQty
type Keys = keyof QtyHistoryColumns
type ColumnsTypes = {
    [key in Keys]: Types.Columns<ProductTypes.HistoryQty>
}

export const columnsQtyHistory: ColumnsTypes = {
    imageUrl: {
        header: 'Gambar',
        render: (v) => <Text>{v.imageUrl}</Text>,
    },
    id: {
        header: 'ID',
        render: (v) => <Text>{v.id}</Text>,
    },
    createdAt: {
        header: 'Tanggal Dibuat',
        render: (v) => <Text>{Shared.FormatDateToString(v.createdAt)}</Text>,
    },
    description: {
        header: 'Deskripsi',
        render: (v) => <Text>{v.description}</Text>,
    },
    size: {
        header: 'Ukuran',
        render: (v) => <Text>{v.size}</Text>,
    },
    warehouse: {
        header: 'Gudang',
        render: (v) => (
            <>
                {v.warehouse.length > 0 && (
                    <UnorderedList>
                        {v.warehouse.map((i, idx) => {
                            if (i !== null) {
                                return (
                                    <ListItem key={idx}>
                                        <Text>{i?.name}</Text>
                                        <Text>{i?.qty}</Text>
                                    </ListItem>
                                )
                            }
                        })}
                    </UnorderedList>
                )}
                {/* {v.warehouse.length === 0 && <Text>-</Text>} */}
            </>
        ),
    },
    creator: {
        header: 'Asal',
        render: (v) => (
            <Box experimental_spaceY={2} fontSize={'sm'}>
                {v.creator ? (
                    <StackAvatar
                        imageUrl={v.creator.imageUrl}
                        name={v.creator.name}
                    />
                ) : (
                    '-'
                )}
            </Box>
        ),
    },
    type: {
        header: 'Tipe',
        render: (v) => <Text>{entity.team(String(v.type))}</Text>,
    },

    qty: {
        header: 'Jumlah',
        render: (v) => <Text>{v.qty}</Text>,
    },

    branchId: {
        header: 'Cabang',
        render: (v) => <Text>{v.branchId}</Text>,
    },
    productId: {
        header: 'Produk Id',
        render: (v) => <Text>{v.productId}</Text>,
    },
    brand: {
        header: 'Brand',
        render: (v) => <Text>{v.brand.name}</Text>,
    },
    category: {
        header: 'Category',
        render: (v) => <Text>{v.category.name}</Text>,
    },
    name: {
        header: 'Nama',
        render: (v) => <StackAvatar imageUrl={v.imageUrl} name={v.name} />,
    },
}
