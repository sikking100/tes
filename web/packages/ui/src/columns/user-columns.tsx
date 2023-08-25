import { Text } from '@chakra-ui/layout'
import { Types, Shared } from 'ui'
// import type { DataTypes } from 'api'
import { StackAvatar } from '../stack-avatar'
import { splitText } from '../utils/shared'
import { Customers } from 'apis'

type UserTypes = Omit<
    Customers,
    | 'imageUrl'
    | 'idCardPath'
    | 'idCardNumber'
    | 'fcmToken'
    | 'business'
    | 'credit_'
    | 'sales_'
    | 'categoryPrice_'
>
type Keys = keyof UserTypes
type ColumnsTypes = {
    [key in Keys]: Types.Columns<Customers>
}

export const columnsUser: ColumnsTypes = {
    id: {
        header: 'ID',
        render: (v) => <Text>{v.id}</Text>,
    },
    name: {
        header: 'Nama',
        render: (v) => (
            <StackAvatar
                imageUrl={`${v.imageUrl}`}
                name={splitText(v.name, 15)}
            />
        ),
    },
    phone: {
        header: 'Nomor HP',
        render: (v) => <Text>{v.phone}</Text>,
    },
    email: {
        header: 'Email',
        render: (v) => <Text>{v.email}</Text>,
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
