import { Text } from '@chakra-ui/layout'
import { Region } from 'apis'
import { Types, Shared } from 'ui'

type RegionTypes = Region
type Keys = keyof RegionTypes
type ColumnsTypes = {
    [key in Keys]: Types.Columns<Region>
}

export const columnsRegion: ColumnsTypes = {
    id: {
        header: 'ID Region',
        render: (v) => <Text>{v.id}</Text>,
    },
    createdAt: {
        header: 'Tanggal Dibuat',
        render: (v) => <Text>{Shared.FormatDateToString(v.createdAt)}</Text>,
    },
    name: {
        header: 'Nama Region',
        render: (v) => <Text>{v.name}</Text>,
    },
    updatedAt: {
        header: 'Tanggal Diperbarui',
        render: (v) => <Text>{Shared.FormatDateToString(v.updatedAt)}</Text>,
    },
}
