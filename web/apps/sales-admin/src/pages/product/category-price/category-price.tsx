// import React from 'react'
// import { Link, useSearchParams } from 'react-router-dom'
// import { ButtonTooltip, CardDetailBranch, Columns, Icons, ModalsSelectBranch, PText, PagingButton, Root, Tables, Types } from 'ui'
// import { DataTypes, categoryPriceService, store, useQueryParam } from 'api'
// import { SearchInputInTag } from '../search-input-tag'
// import { listNavigation, setHeight } from '~/utils'
// import { HStack } from '@chakra-ui/react'
// import { setQueryGet } from '../warehouse/warehouse'

// const Wrap: React.FC<{ children: React.ReactNode }> = ({ children }) => {
//     const admin = store.useStore((i) => i.admin)

//     const list = listNavigation(Number(admin?.roles))

//     return (
//         <Root appName="Sales" items={list} backUrl={'/'} activeNum={4}>
//             {children}
//         </Root>
//     )
// }

// const CategoryPricePages = () => {
//     const admin = store.useStore((i) => i.admin)

//     const [searchParams] = useSearchParams()
//     const [isOpenBranch, setOpenBranch] = React.useState(true)
//     const { column } = colums()

//     const { data, page, setPage, setQ } = categoryPriceService.useGetCategoryPrice({
//         query: setQueryGet(admin!),
//     })

//     return (
//         <Wrap>
//             {admin?.roles === 3 && <ModalsSelectBranch isOpenBranch={isOpenBranch} setOpenBranch={setOpenBranch} />}
//             <CardDetailBranch branchId={setQueryGet(admin!)} />

//             <SearchInputInTag setQ={setQ} setOpenBranch={setOpenBranch} label="Cari Kategori Harga" roles={admin?.roles} />
//             {data.isError ? (
//                 <PText label={data.error.message} />
//             ) : (
//                 <Tables columns={column} isLoading={data.isLoading} data={data.isLoading ? [] : data.data.data.items} pageH={setHeight()} />
//             )}
//             <PagingButton
//                 page={page}
//                 nextPage={() => setPage(page + 1)}
//                 prevPage={() => setPage(page - 1)}
//                 disableNext={data.data?.data.next === null}
//             />
//         </Wrap>
//     )
// }

// export default CategoryPricePages

// const colums = () => {
//     const qParam = useQueryParam()

//     const cols = Columns.columnsCategoryPrice
//     const [id, setId] = React.useState<DataTypes.CategoryPriceTypes.CategoryPrice | undefined>()
//     const [isOpen, setOpen] = React.useState(false)
//     const [isOpenBranch, setOpenBranch] = React.useState(false)

//     const column: Types.Columns<DataTypes.CategoryPriceTypes.CategoryPrice>[] = [
//         cols.name,
//         cols.branch,
//         cols.team,
//         cols.createdAt,
//         cols.updatedAt,
//         {
//             header: 'Tindakan',
//             render: (v) => (
//                 <HStack>
//                     <Link to={`/price?category-price-id=${v.id}&${qParam}`}>
//                         <ButtonTooltip label={'Produk'} icon={<Icons.ProductIcons color={'gray'} />} />
//                     </Link>
//                     <Link to={`/category-price/${v.id}?${qParam}`}>
//                         <ButtonTooltip label={'Detail'} icon={<Icons.IconDetails color={'gray'} />} />
//                     </Link>
//                 </HStack>
//             ),
//         },
//     ]

//     return { column, id, isOpen, setOpen, setOpenBranch, isOpenBranch }
// }
