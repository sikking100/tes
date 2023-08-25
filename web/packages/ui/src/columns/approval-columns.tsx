// import { HStack, Text } from '@chakra-ui/layout'
// import { Types, Shared } from 'ui'
// import type { DataTypes } from 'api'
// import { StackAvatar } from '../stack-avatar'

// type ApprovalTypes = DataTypes.ApprovalTypes.Approval
// type Keys = keyof ApprovalTypes
// type ColumnsTypes = {
//   [key in Keys]: Types.Columns<DataTypes.ApprovalTypes.Approval>
// }

// export const columnsApproval: ColumnsTypes = {
//   createdAt: {
//     header: 'Tanggal Dibuat',
//     render: (v) => <Text>{Shared.FormatDateToString(v.createdAt)}</Text>,
//   },
//   createdBy: {
//     header: 'Dibuat Oleh',
//     render: (v) => <StackAvatar imageUrl={v.createdBy.imageUrl} name={v.createdBy.name} />,
//   },
//   branch: {
//     header: 'Cabang',
//     render: (v) => <Text>{v.branch.name}</Text>,
//   },
//   customer: {
//     header: 'Pelanggan',
//     render: (v) => <StackAvatar imageUrl={v.customer.imageUrl} name={v.customer.name} />,
//   },
//   id: {
//     header: 'ID',
//     render: (v) => <Text>{v.id}</Text>,
//   },
//   status: {
//     header: 'Status',
//     render: (v) => <Text>{v.status}</Text>,
//   },
//   team: {
//     header: 'Tim',
//     render: (v) => <Text>{v.team}</Text>,
//   },
//   type: {
//     header: 'Tipe',
//     render: (v) => <Text>{v.type}</Text>,
//   },
//   updatedAt: {
//     header: 'Tanggal Diperbarui',
//     render: (v) => <Text>{Shared.FormatDateToString(v.updatedAt)}</Text>,
//   },
//   userApprover: {
//     header: 'Approver',
//     render: (v) => <StackAvatar imageUrl={v.userApprover.imageUrl} name={v.userApprover.name} />,
//   },
// }
