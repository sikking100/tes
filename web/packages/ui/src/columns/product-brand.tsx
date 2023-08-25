import { Text } from '@chakra-ui/layout'
import { Types, Shared } from 'ui'
import type { Brand } from 'apis'
import { StackAvatar } from '../stack-avatar'

type BrandTypes = Omit<Brand, 'imageUrl' | 'newImage'>
type Keys = keyof BrandTypes
type ColumnsTypes = {
    [key in Keys]: Types.Columns<Brand>
}

export const columnsBrand: ColumnsTypes = {
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
        render: (v) => <StackAvatar name={v.name} imageUrl={v.imageUrl} />,
    },
    updatedAt: {
        header: 'Tanggal Diperbarui',
        render: (v) => <Text>{Shared.FormatDateToString(v.updatedAt)}</Text>,
    },
}
