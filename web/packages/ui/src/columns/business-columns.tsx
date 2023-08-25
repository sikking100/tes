// import { Text } from '@chakra-ui/layout'
// import { Types, Shared } from 'ui'
// import { DataTypes, entity } from 'api'
// import { Badges, StackAvatar } from '../stack-avatar'
// import { FormatDateToString, splitText } from '../utils/shared'
// import { UnorderedList, ListItem } from '@chakra-ui/react'

// //  branchAdmin,
// // expiredAt,salesAdmin,salesFood,salesRetail,tax

// type Keys = keyof BusinessTypess

// type BusinessTypess = Omit<
//   DataTypes.CustomerTypes.CustomerApply,
//   | 'branchAdmin'
//   | 'expiredAt'
//   | 'salesFood'
//   | 'salesRetail'
//   | 'tax'
//   | 'imageUrl'
//   | 'salesAdmin'
//   | 'categoryPrice'
//   | 'categoryPrice_'
//   | 'note_'
//   | 'sales_'
//   | 'userApprover'
//   | 'transactionLastMonth'
//   | 'transactionPerMonth'
//   | 'businessId_'
//   | 'customerImage_'
//   | 'image_'
//   | 'picImage_'
//   | 'taxImage_'
//   | 'limit_'
// >

// type ColumnsBusinessTypes = {
//   [key in Keys]: Types.Columns<DataTypes.CustomerTypes.CustomerApply>
// }

// export const columnsBusinessApply: ColumnsBusinessTypes = {
//   address: {
//     header: 'Alamat Pengiriman',
//     render: (item) => (
//       <Text as='span'>
//         {item.address.length > 0 ? (
//           <UnorderedList>
//             {item.address.map((b) => (
//               <ListItem>{splitText(b.name, 35)}</ListItem>
//             ))}
//           </UnorderedList>
//         ) : (
//           '-'
//         )}
//       </Text>
//     ),
//   },
//   creditActual: {
//     header: 'Actual TOP',
//     render: (item) => <Text>{Shared.formatRupiah(`${item.creditActual.limit}`)}</Text>,
//   },
//   creditLimit: {
//     header: 'Limit TOP',
//     render: (item) => <Text>{Shared.formatRupiah(`${item.creditLimit.limit}`)}</Text>,
//   },
//   creditProposal: {
//     header: 'Pengajuan TOP',
//     render: (item) => <Text>{Shared.formatRupiah(`${item.creditProposal.limit}`)}</Text>,
//   },
//   id: {
//     header: 'ID',
//     render: (item) => <Text>{item.id}</Text>,
//   },
//   createdAt: {
//     header: 'Tanggal Dibuat',
//     render: (item) => <Text>{FormatDateToString(item.createdAt)}</Text>,
//   },

//   status: {
//     header: 'Status',
//     render: (item) => <Text>{entity.entity.statusApply(item.status)}</Text>,
//   },
//   createdBy: {
//     header: 'Diajukan Oleh',
//     render: (item) => <StackAvatar imageUrl={item.createdBy.imageUrl} name={item.createdBy.name} />,
//   },
//   customer: {
//     header: 'Nama Usaha',
//     render: (item) => <StackAvatar imageUrl={item.customer.imageUrl} name={item.customer.name} />,
//   },
//   pic: {
//     header: 'PIC',
//     render: (item) => <StackAvatar imageUrl={item.pic.imageUrl} name={item.pic.name} />,
//   },
//   updatedAt: {
//     header: 'Tanggal Diubah',
//     render: (item) => <Text>{FormatDateToString(item.updatedAt)}</Text>,
//   },
// }
