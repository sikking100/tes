// import React from 'react'
// import {
//   ButtonTooltip,
//   CardDetailBranch,
//   Columns,
//   Icons,
//   PagingButton,
//   PText,
//   Root,
//   Shared,
//   Tables,
//   Types,
// } from 'ui'
// import { Box, Text } from '@chakra-ui/layout'
// import { DataTypes, categoryPriceService, priceService, store, useQueryParam } from 'api'
// import { Link, useSearchParams } from 'react-router-dom'
// import { SearchInputInTag } from '../search-input-tag'
// import { listNavigation, setHeight } from '~/utils'
// import { Avatar, HStack } from '@chakra-ui/react'

// const Wrap: React.FC<{ children: React.ReactNode }> = ({ children }) => {
//   const admin = store.useStore((i) => i.admin)

//   const qParam = useQueryParam()
//   const list = listNavigation(Number(admin?.roles))

//   return (
//     <Root appName='System' items={list} backUrl={`/category-price?${qParam}`} activeNum={4}>
//       {children}
//     </Root>
//   )
// }

// const CardDetail: React.FC<{ priceId: string }> = ({ priceId }) => {
//   const { data } = categoryPriceService.useCategoryPriceById(priceId)

//   return (
//     <Box mb={2} bg='white' px={3} py={2} rounded={'xl'}>
//       {data.isError ? (
//         <PText label={data.error.message} />
//       ) : data.isLoading ? (
//         <PText label={'Loading...'} />
//       ) : (
//         <React.Fragment>
//           <Box>
//             <Text fontWeight={'semibold'} fontSize={'lg'}>
//               {data.data.data.name}
//             </Text>
//             <Text fontWeight={'semibold'} fontSize={'sm'}>
//               {data.data.data.team}
//             </Text>
//           </Box>
//         </React.Fragment>
//       )}
//     </Box>
//   )
// }
// const PricePages = () => {
//   const admin = store.useStore((i) => i.admin)

//   const [searchParams] = useSearchParams()
//   const [isOpenBranch, setOpenBranch] = React.useState(true)
//   const { column } = columns()
//   const { data, page, setPage, setQ } = priceService.useGetPrice({
//     priceId: String(searchParams.get('category-price-id')),
//   })

//   return (
//     <Wrap>
//       <CardDetailBranch branchId={String(searchParams.get('branchId'))} />

//       <SearchInputInTag
//         label='Cari Produk'
//         setOpenBranch={setOpenBranch}
//         setQ={setQ}
//         roles={admin?.roles}
//       />
//       {data.isError ? (
//         <PText label={data.error.message} />
//       ) : (
//         <Tables
//           columns={column}
//           isLoading={data.isLoading}
//           pageH={setHeight()}
//           data={data.isLoading ? [] : data.data.data.items}
//         />
//       )}
//       <PagingButton
//         page={page}
//         nextPage={() => setPage(page + 1)}
//         prevPage={() => setPage(page - 1)}
//         disableNext={data.data?.data.next === null}
//       />
//     </Wrap>
//   )
// }

// export default PricePages

// const columns = () => {
//   const cols = Columns.columnsPrice
//   const qParam = useQueryParam()

//   const [id, setId] = React.useState<DataTypes.PriceTypes.Price | undefined>()
//   const [isOpen, setOpen] = React.useState(false)

//   const column: Types.Columns<DataTypes.PriceTypes.Price>[] = [
//     cols.categoryPrice,
//     cols.price,
//     {
//       header: 'Produk',
//       render: (v) => (
//         <HStack>
//           <Avatar src={v.product.imageUrl} size={'sm'} />
//           <Box>
//             <Text>{Shared.splitText(v.product.name, 20)}</Text>
//             <Text fontSize={'12px'}>
//               {v.product.category.name}, {v.product.size}
//             </Text>
//           </Box>
//         </HStack>
//       ),
//     },
//     cols.createdAt,
//     cols.updatedAt,
//     {
//       header: 'Tindakan',
//       render: (v) => (
//         <HStack>
//           <Link to={`/price/detail?${qParam}&priceId=${v.id}`}>
//             <ButtonTooltip label={'Detail'} icon={<Icons.IconDetails color={'gray'} />} />
//           </Link>
//         </HStack>
//       ),
//     },
//   ]

//   return { column, id, isOpen, setOpen }
// }
