// import { Text } from '@chakra-ui/layout'
// import { Types, Shared } from 'ui'
// import { DataTypes, entity } from 'api'

// type CategoryPriceTypes = Omit<DataTypes.CategoryPriceTypes.CategoryPrice, 'branch_'>
// type Keys = keyof CategoryPriceTypes
// type ColumnsTypes = {
//   [key in Keys]: Types.Columns<DataTypes.CategoryPriceTypes.CategoryPrice>
// }

// export const columnsCategoryPrice: ColumnsTypes = {
//   id: {
//     header: 'ID',
//     render: (v) => <Text>{v.id}</Text>,
//   },
//   createdAt: {
//     header: 'Tanggal Dibuat',
//     render: (v) => <Text>{Shared.FormatDateToString(v.createdAt)}</Text>,
//   },
//   branch: {
//     header: 'Cabang',
//     render: (v) => <Text>{v.branch.name}</Text>,
//   },
//   team: {
//     header: 'Kategori',
//     render: (v) => <Text>{entity.entity.team(String(v.team))}</Text>,
//   },
//   name: {
//     header: 'Nama',
//     render: (v) => <Text>{v.name}</Text>,
//   },
//   updatedAt: {
//     header: 'Tanggal Diperbarui',
//     render: (v) => <Text>{Shared.FormatDateToString(v.updatedAt)}</Text>,
//   },
// }
