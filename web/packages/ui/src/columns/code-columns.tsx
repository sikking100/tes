import { Text } from '@chakra-ui/layout'
import { Code } from 'apis'
import { Types, Shared } from 'ui'

type CodeTypes = Code
type Keys = keyof CodeTypes
type ColumnsTypes = {
    [key in Keys]: Types.Columns<Code>
}

export const columnsCode: ColumnsTypes = {
    id: {
        header: 'ID',
        render: (v) => <Text>{v.id}</Text>,
    },
    description: {
        header: 'Deskripsi',
        render: (v) => <Text>{v.description}</Text>,
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
