// import React from 'react'
// import {
//     Editable,
//     EditableInput,
//     EditablePreview,
//     Table,
//     Tbody,
//     Td,
//     Th,
//     Thead,
//     Tr,
//     TableContainer,
//     Checkbox,
//     Box,
//     HStack,
// } from '@chakra-ui/react'
// import { DataTypes, usePickImage } from 'api'
// import { BreadCrumb, Buttons, ImagePick, Root } from 'ui'

// type ProductImportTypes = DataTypes.ProductTypes.ProductImportRequest

// interface Props {
//     headerRow: string[]
// }

// const PreviewImportPages: React.FC<Props> = (props) => {
//     const { headerRow } = props
//     const [isCheckAll, setIsCheckAll] = React.useState(false)
//     const [isCheck, setIsCheck] = React.useState<ProductImportTypes[]>([])
//     const [data, setData] = React.useState<ProductImportTypes[]>([])

//     React.useEffect(() => {
//         const dataLocal = localStorage.getItem('product-import')
//         const dataParse = JSON.parse(String(dataLocal)) as ProductImportTypes[]
//         setData(dataParse)
//     }, [])

//     React.useEffect(() => {
//         // console.log('isCheck', isCheck)
//     }, [isCheck])

//     const handleSelectAll = (e: any) => {
//         setIsCheckAll(!isCheckAll)
//         setIsCheck(data.map((li) => li))
//         if (isCheckAll) {
//             setIsCheck([])
//         }
//     }

//     const handleClick = (e: any) => {
//         const { id, checked } = e.target
//         const parseData = JSON.parse(String(id)) as ProductImportTypes
//         setIsCheck([...isCheck, parseData])
//         if (!checked) {
//             setIsCheck(
//                 isCheck.filter((item) => item.productId !== parseData.productId)
//             )
//         }
//     }

//     const catalog = (req: ProductImportTypes) => {
//         return (
//             <>
//                 <Checkbox
//                     id={JSON.stringify(req)}
//                     onChange={handleClick}
//                     isChecked={isCheck.some(
//                         (v) => v.productId === req.productId
//                     )}
//                 ></Checkbox>
//             </>
//         )
//     }

//     const AfterHover = (e: any) => {
//         console.log(e.target.value)
//     }

//     const removeRows = () => {
//         isCheck.map((v, kv) => {
//             setData((i) => i.filter((it) => it.productId !== v.productId))
//         })
//     }

//     return (
//         <Box>
//             <HStack pb={3}>
//                 <Buttons
//                     onClick={() => {
//                         const ds: DataTypes.ProductTypes.ProductImportRequest =
//                             {
//                                 brand: 'brand',
//                                 category: 'category',
//                                 description: 'description',
//                                 name: 'name',
//                                 productId: 'productId',
//                                 size: 'size',
//                                 team: 'team',
//                                 weight: 0,
//                                 imageUrl: 'imageUrl',
//                             }
//                         setData((i) => [
//                             ...i,
//                             { ...ds, productId: `${Date.now()}` },
//                         ])
//                     }}
//                     label="Tambah Baris"
//                 />
//                 <Buttons label="Hapus" onClick={removeRows} />
//                 <Buttons label="Simpan" />
//             </HStack>
//             <Box minH={'83vh'} maxH={'83vh'} overflow={'auto'}>
//                 <TableContainer>
//                     <Table size="sm" bg="white" p={2} rounded={'md'}>
//                         <Thead height={'40px !important'}>
//                             <Tr>
//                                 {headerRow.map((v, k) => {
//                                     if (k === 0) {
//                                         return (
//                                             <Th key={v} w={'10px !important'}>
//                                                 <Checkbox
//                                                     name="selectAll"
//                                                     id="selectAll"
//                                                     onChange={handleSelectAll}
//                                                     isChecked={isCheckAll}
//                                                 ></Checkbox>
//                                             </Th>
//                                         )
//                                     } else {
//                                         return (
//                                             <Th
//                                                 key={v}
//                                                 fontSize={'14px !important'}
//                                             >
//                                                 {v}
//                                             </Th>
//                                         )
//                                     }
//                                 })}
//                             </Tr>
//                         </Thead>
//                         <Tbody>
//                             <>
//                                 {data.map((i, k) => {
//                                     return (
//                                         <Tr key={k}>
//                                             <Td>{catalog(i)}</Td>
//                                             <Td>
//                                                 <Editable
//                                                     defaultValue={i.productId}
//                                                 >
//                                                     <EditablePreview />
//                                                     <EditableInput
//                                                         onMouseOut={AfterHover}
//                                                     />
//                                                 </Editable>
//                                             </Td>
//                                             <Td>
//                                                 <Editable defaultValue={i.name}>
//                                                     <EditablePreview />
//                                                     <EditableInput
//                                                         onMouseOut={AfterHover}
//                                                     />
//                                                 </Editable>
//                                             </Td>
//                                             <Td>
//                                                 <Editable defaultValue={i.size}>
//                                                     <EditablePreview />
//                                                     <EditableInput
//                                                         onMouseOut={AfterHover}
//                                                     />
//                                                 </Editable>
//                                             </Td>
//                                             <Td>
//                                                 <Editable defaultValue={i.team}>
//                                                     <EditablePreview />
//                                                     <EditableInput
//                                                         onMouseOut={AfterHover}
//                                                     />
//                                                 </Editable>
//                                             </Td>
//                                             <Td>
//                                                 <Editable
//                                                     defaultValue={i.category}
//                                                 >
//                                                     <EditablePreview />
//                                                     <EditableInput
//                                                         onMouseOut={AfterHover}
//                                                     />
//                                                 </Editable>
//                                             </Td>
//                                             <Td>
//                                                 <Editable
//                                                     defaultValue={i.brand}
//                                                 >
//                                                     <EditablePreview />
//                                                     <EditableInput
//                                                         onMouseOut={AfterHover}
//                                                     />
//                                                 </Editable>
//                                             </Td>
//                                             <Td>
//                                                 <Editable
//                                                     defaultValue={`${i.weight}`}
//                                                 >
//                                                     <EditablePreview />
//                                                     <EditableInput
//                                                         onMouseOut={AfterHover}
//                                                     />
//                                                 </Editable>
//                                             </Td>
//                                         </Tr>
//                                     )
//                                 })}
//                             </>
//                         </Tbody>
//                     </Table>
//                 </TableContainer>
//             </Box>
//             <Box>
//                 <BreadCrumb
//                     item={[
//                         { label: 'Produk', href: '/product' },
//                         { label: 'Import Data', href: '/import/product' },
//                     ]}
//                 />
//             </Box>
//         </Box>
//     )
// }

// export default PreviewImportPages
export {}
