import { Text } from '@chakra-ui/layout'
import { Badges, StackAvatar } from '../stack-avatar'
import { FormatDateToString, formatRupiah } from '../utils/shared'
import { Shared, Types } from '..'
import { OrderApply } from 'apis'
import { entity } from '../utils'

type KeysOrderApply = keyof Omit<OrderApply, 'userApprover'>
type ColumnsPaylaterTypes = {
    [key in KeysOrderApply]: Types.Columns<OrderApply>
}

export const columnsOrderApply: ColumnsPaylaterTypes = {
    id: {
        header: 'ID',
        render: (v) => <Text>{v.id}</Text>,
    },
    expiredAt: {
        header: 'Expired At',
        render: (v) => <Text>{FormatDateToString(v.expiredAt)}</Text>,
    },
    overDue: {
        header: 'OverDue',
        render: (v) => <Text>{Shared.formatRupiah(String(v.overDue))}</Text>,
    },
    overLimit: {
        header: 'Over Limit',
        render: (v) => <Text>{Shared.formatRupiah(String(v.overLimit))}</Text>,
    },
    status: {
        header: 'Status',
        render: (v) => <Text>{entity.statusOrderApply(v.status)}</Text>,
    },
}
