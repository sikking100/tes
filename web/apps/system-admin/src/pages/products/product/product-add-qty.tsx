// import React from 'react'
// import { DataTypes, productService, qtyService, store, useSearchs } from 'api'
// import { useNavigate, useParams, useSearchParams } from 'react-router-dom'
// import { useForm } from 'react-hook-form'
// import {
//     ButtonForm,
//     FormControls,
//     FormSelects,
//     LoadingForm,
//     Modals,
//     PText,
// } from 'ui'
// import {
//     Box,
//     Divider,
//     HStack,
//     SimpleGrid,
//     Text,
//     VStack,
// } from '@chakra-ui/layout'
// import { Avatar } from '@chakra-ui/react'

// type QtyReq = DataTypes.QtyTypes.QtyRequest
// interface ListWareProductProps {
//     isOpen: boolean
//     setOpen: (v: boolean) => void
//     branchId: string
//     productId: string
//     dataProduct: DataTypes.ProductTypes.Product
// }

// const setObjectQuery = (): {} => {
//     const [searchParams] = useSearchParams()
//     if (searchParams.get('branch')) {
//         return {
//             query: searchParams.get('branch'),
//         }
//     }

//     return {
//         s: '',
//     }
// }

// const ModalTableListWarehouseProduct: React.FC<ListWareProductProps> = (
//     props
// ) => {
//     if (!props.isOpen) return <></>
//     const params = useParams()
//     const [searchParams] = useSearchParams()
//     const { data: dataQtyWare } = qtyService.useGetProductByWarehouse({
//         branchId: `${searchParams.get('branch')}`,
//         productId: `${params.id}`,
//     })
//     const dataProduct = props.dataProduct

//     return (
//         <Modals
//             isOpen={props.isOpen}
//             setOpen={props.setOpen}
//             title="List Gudang"
//             size="5xl"
//         >
//             {dataQtyWare.isLoading ? (
//                 <Text>Loading...</Text>
//             ) : (
//                 <Box
//                     fontSize={'sm'}
//                     minH={'400px'}
//                     maxH={'400px'}
//                     overflow={'auto'}
//                     experimental_spaceY={5}
//                 >
//                     <HStack align={'start'} spacing={2}>
//                         <Avatar
//                             src={dataProduct.imageUrl}
//                             name={dataProduct.name}
//                             size="md"
//                         />
//                         <VStack align={'start'} spacing={0}>
//                             <Text>{dataProduct.name}</Text>
//                             <Text>{dataProduct.category.name}</Text>
//                         </VStack>
//                         <VStack align={'start'} spacing={0}>
//                             <Text>{dataProduct.brand.name}</Text>
//                             <Text>{dataProduct.size}</Text>
//                         </VStack>
//                     </HStack>
//                     {dataQtyWare.data?.data.map((v, idx) => (
//                         <Box key={idx} experimental_spaceY={5}>
//                             <SimpleGrid columns={5} gap={10}>
//                                 <Box>
//                                     <Text fontWeight={'bold'}>Nama Cabang</Text>
//                                     <Text>{v.warehouse.name}</Text>
//                                 </Box>
//                                 <Box>
//                                     <Text fontWeight={'bold'}>
//                                         No Hp Cabang
//                                     </Text>
//                                     <Text>{v.warehouse.phone}</Text>
//                                 </Box>
//                                 <Box>
//                                     <Text fontWeight={'bold'}>
//                                         Cabang Gudang
//                                     </Text>
//                                     <Text>{v.warehouse.branch.name}</Text>
//                                 </Box>
//                                 <Box>
//                                     <Text fontWeight={'bold'}>
//                                         Alamat Gudang
//                                     </Text>
//                                     <Text>{v.warehouse.address.name}</Text>
//                                 </Box>
//                                 <Box>
//                                     <Text fontWeight={'bold'}>
//                                         Stok Digudang
//                                     </Text>
//                                     <Text>{v.qty}</Text>
//                                 </Box>
//                             </SimpleGrid>
//                             <Divider />
//                         </Box>
//                     ))}
//                 </Box>
//             )}
//         </Modals>
//     )
// }

// const ProdcutAddQtyPages = () => {
//     const params = useParams()

//     const {
//         handleSubmit,
//         register,
//         watch,
//         getValues,
//         control,
//         reset,
//         formState: { errors },
//     } = useForm<QtyReq>({})
//     const navigate = useNavigate()
//     const admin = store.useStore((i) => i.admin)

//     const warehouseSearch = useSearchs<DataTypes.WarehouseTypes.Warehouse>(
//         'warehouse',
//         setObjectQuery()
//     )
//     const [branchs, setBranchs] = React.useState('')
//     const [isOpenListWarehouse, setOpenListWarehouse] = React.useState(false)
//     const branchSearch = useSearchs<DataTypes.BranchTypes.Branch>('branch')
//     const { create } = qtyService.useQty()
//     const { data } = productService.useProductById(String(params.id))

//     React.useEffect(() => {
//         if (data.isSuccess) {
//             const dataProduct = data.data.data
//             reset({
//                 product: dataProduct,
//             })
//         }
//     }, [data.isSuccess])

//     React.useEffect(() => {
//         if (watch('branch_')) {
//             const branchVal = JSON.parse(
//                 getValues('branch_.value')
//             ) as DataTypes.BranchTypes.Branch
//             setBranchs(branchVal.id)
//             onSearchWarehouse(branchVal.id)
//         }
//     }, [watch('branch_'), setObjectQuery()])

//     const onSearchWarehouse = (idBrach: string) => {
//         navigate(`/product/${params.id}/add-stock?branch=${idBrach}`)
//     }

//     const onSubmit = async (data: QtyReq) => {
//         const dataWarehouse = JSON.parse(
//             getValues('warehouse_.value')
//         ) as DataTypes.WarehouseTypes.Warehouse

//         const ReqData: DataTypes.QtyTypes.QtyRequest = {
//             ...data,
//             createdBy: {
//                 id: `${admin?.id}`,
//                 name: `${admin?.name}`,
//                 phone: `${admin?.phone}`,
//                 roles: Number(admin?.roles),
//             },
//             to: {
//                 id: `${dataWarehouse.id}`,
//                 address: {
//                     name: `${dataWarehouse.address.name}`,
//                     lngLat: `${dataWarehouse.address.lngLat}`,
//                 },
//                 name: `${dataWarehouse.name}`,
//                 phone: `${dataWarehouse.phone}`,
//                 branch: dataWarehouse.branch,
//                 createdAt: `${dataWarehouse.createdAt}`,
//                 updatedAt: `${dataWarehouse.updatedAt}`,
//             },
//             qty: Number(data.qty),
//         }

//         await create.mutateAsync(ReqData)
//         navigate('/product', { replace: true })
//     }

//     return (
//         <Modals
//             isOpen={true}
//             setOpen={() => navigate(`/product`)}
//             size={'3xl'}
//             title="Tambah Stok"
//             scrlBehavior="outside"
//         >
//             {data.isError ? (
//                 <PText label={data.error.message} />
//             ) : data.isLoading ? (
//                 <LoadingForm />
//             ) : (
//                 <React.Fragment>
//                     <ModalTableListWarehouseProduct
//                         branchId={branchs}
//                         isOpen={isOpenListWarehouse}
//                         setOpen={() => setOpenListWarehouse(false)}
//                         productId={`${params.id}`}
//                         dataProduct={data.data.data}
//                     />
//                     <form onSubmit={handleSubmit(onSubmit)}>
//                         <Box experimental_spaceY={3}>
//                             <FormSelects
//                                 async
//                                 loadOptions={branchSearch}
//                                 label="branch_"
//                                 title={'Cabang'}
//                                 placeholder="Pilih Cabang"
//                                 control={control}
//                                 errors={errors.branch_?.message}
//                             />
//                             <Text
//                                 textDecor={'underline'}
//                                 cursor={'pointer'}
//                                 onClick={() => setOpenListWarehouse(true)}
//                             >
//                                 Lihat Stok Di Gudang
//                             </Text>
//                             <FormSelects
//                                 async
//                                 defaultOptions={false}
//                                 loadOptions={warehouseSearch}
//                                 label="warehouse_"
//                                 title={'Gudang'}
//                                 placeholder="Pilih Gudang"
//                                 control={control}
//                                 errors={errors.warehouse_?.message}
//                             />

//                             <FormControls
//                                 type={'number'}
//                                 label="qty"
//                                 title={'Jumlah Stok'}
//                                 register={register}
//                                 errors={errors.qty?.message}
//                                 required={'Jumlah Stok tidak boleh kosong'}
//                             />
//                         </Box>
//                         <ButtonForm
//                             label={'Simpan'}
//                             isLoading={create.isLoading}
//                             onClose={() => navigate(`/product`)}
//                         />
//                     </form>
//                 </React.Fragment>
//             )}
//         </Modals>
//     )
// }

// export default ProdcutAddQtyPages
