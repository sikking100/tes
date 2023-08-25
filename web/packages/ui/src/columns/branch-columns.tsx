import { Text } from '@chakra-ui/layout'
import { Types, Shared } from 'ui'
import type { Branch } from 'apis'
import { splitText } from '../utils/shared'

type BranchTypes = Omit<Branch, 'warehouse'>
type Keys = keyof BranchTypes
type ColumnsTypes = {
    [key in Keys]: Types.Columns<Branch>
}

export const columnsBranch: ColumnsTypes = {
    createdAt: {
        header: 'Tanggal Dibuat',
        render: (v) => <Text>{Shared.FormatDateToString(v.createdAt)}</Text>,
    },
    id: {
        header: 'ID Cabang',
        render: (v) => <Text>{v.id}</Text>,
    },
    region: {
        header: 'Region',
        render: (v) => <Text>{v.region.name}</Text>,
    },
    address: {
        header: 'Alamat',
        render: (v) => <Text>{splitText(v.address.name, 40)}</Text>,
    },
    name: {
        header: 'Nama Cabang',
        render: (v) => <Text>{v.name}</Text>,
    },
    updatedAt: {
        header: 'Tanggal Diperbarui',
        render: (v) => <Text>{Shared.FormatDateToString(v.updatedAt)}</Text>,
    },
}
