// import React from 'react'
// import { Box, HStack, Input, Checkbox } from '@chakra-ui/react'
// import { useSearchParams } from 'react-router-dom'
// import { productService, branchService } from 'hooks'
// import { Columns, PText, Root, Tables, Types } from 'ui'
// import Selects from 'react-select'
// import { dataListProduct } from '~/navigation'
// import type { ProductTypes, SelectsTypes } from 'apis'

// const Wrap: React.FC<{ children: React.ReactNode }> = ({ children }) => (
//     <Root appName="System" items={dataListProduct} backUrl={'/'} activeNum={6}>
//         {children}
//     </Root>
// )

// interface ProductImport extends ProductTypes.Product {
//     isCheck: boolean
//     qty: number
// }

// type ReqCheckProduct = React.Dispatch<React.SetStateAction<ProductImport[]>>

// const QtyImportPages = () => {
//     const [searchParams] = useSearchParams()
//     const { data, error, isLoading } = productService.useGetProduct({})
//     const { data: dataBranch } = branchService.useGetBranchId(`${searchParams.get('branchId')}`)
//     const [loadScreen, setLoadScreen] = React.useState(true)
//     const [dataProduct, setDataProduct] = React.useState<ProductImport[]>([])
//     const [warehouse, setWarehouse] = React.useState<SelectsTypes[]>([])
//     const { column } = columns(dataProduct, setDataProduct)

//     React.useEffect(() => {
//         if (data) {
//             const dataTransform: ProductImport[] = []
//             data.forEach((i) => {
//                 dataTransform.push({
//                     ...i,
//                     isCheck: true,
//                     qty: 0,
//                 })
//             })
//             setDataProduct(dataTransform)
//             setLoadScreen(false)
//         }
//         if (dataBranch) {
//             const data: SelectsTypes[] = []
//             dataBranch.warehouse.forEach((i) => {
//                 data.push({
//                     label: i.name,
//                     value: JSON.stringify(i),
//                 })
//             })
//             setWarehouse(data)
//         }
//     }, [data, dataBranch])

//     // const onImport = async () => {
//     //     console.log('warehouse', selectedWarehouse)
//     //     console.log('product', dataProduct)
//     // }

//     return (
//         <Wrap>
//             {error ? (
//                 <PText label={error} />
//             ) : (
//                 <>
//                     <HStack bg="white" px={2} pt={1}>
//                         <Box w="400px">
//                             <Selects
//                                 isClearable={true}
//                                 placeholder="Pilih Gudang"
//                                 options={warehouse}
//                                 menuPortalTarget={document.body}
//                                 menuPosition={'fixed'}
//                             />
//                         </Box>
//                         {/* <Buttons label="Import" leftIcon={<Icons.ImportIcons color={'white'} />} onClick={onImport} /> */}
//                     </HStack>
//                     <Tables
//                         columns={column}
//                         isLoading={isLoading || loadScreen}
//                         data={isLoading || loadScreen ? [] : dataProduct}
//                         usePaging={true}
//                     />
//                 </>
//             )}
//         </Wrap>
//     )
// }

// const columns = (dataProduct: ProductImport[], set: ReqCheckProduct) => {
//     const cols = Columns.columnsProduct
//     // const [id, setId] = React.useState<ProductImport | undefined>()
//     const [isOpen, setOpen] = React.useState(false)

//     const onChange = (event: React.ChangeEvent<HTMLInputElement>, id: string) => {
//         let dataEmpty: ProductImport[] = dataProduct
//         if (!event.target.checked) {
//             dataEmpty = dataProduct.filter((v) => v.id !== id)
//         }
//         set(dataEmpty)
//     }

//     const onChangeQty = (e: React.ChangeEvent<HTMLInputElement>, id: string) => {
//         const dataEmpty: ProductImport[] = dataProduct
//         const find = dataEmpty.findIndex((v) => v.id === id)
//         dataEmpty[find].qty = Number(e.target.value)
//         set(dataEmpty)
//     }

//     const column: Types.Columns<ProductImport>[] = [
//         {
//             header: '',
//             render: (v) => (
//                 <Checkbox
//                     defaultChecked={v.isCheck}
//                     onChange={(e) => {
//                         onChange(e, v.id)
//                     }}
//                 ></Checkbox>
//             ),
//         },
//         cols.id,
//         cols.name,
//         cols.point,
//         cols.size,
//         cols.brand,
//         {
//             header: 'Stok',
//             render: (v) => (
//                 <Input
//                     placeholder="Ketik Stok"
//                     type={'number'}
//                     w="200px"
//                     rounded={'md'}
//                     size="sm"
//                     onChange={(e) => {
//                         onChangeQty(e, v.id)
//                     }}
//                 />
//             ),
//         },
//     ]

//     return { column, isOpen, setOpen }
// }

// export default QtyImportPages
