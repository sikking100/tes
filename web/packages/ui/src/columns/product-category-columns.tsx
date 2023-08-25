import { Text } from '@chakra-ui/layout'
import { Types, Shared, entity } from 'ui'
import type { Category } from 'apis'

type ProductCategoryTypes = Category
type Keys = keyof ProductCategoryTypes
type ColumnsTypes = {
    [key in Keys]: Types.Columns<Category>
}

export const columnsProductCategory: ColumnsTypes = {
    id: {
        header: 'ID',
        render: (v) => <Text>{v.id}</Text>,
    },
    createdAt: {
        header: 'Tanggal Dibuat',
        render: (v) => <Text>{Shared.FormatDateToString(v.createdAt)}</Text>,
    },
    name: {
        header: 'Nama',
        render: (v) => <Text>{v.name}</Text>,
    },
    target: {
        header: 'Target',
        render: (v) => <Text>{v.target}</Text>,
    },
    team: {
        header: 'Tim',
        render: (v) => <Text>{entity.team(String(v.team))}</Text>,
    },
    updatedAt: {
        header: 'Tanggal Diperbarui',
        render: (v) => <Text>{Shared.FormatDateToString(v.updatedAt)}</Text>,
    },
}
