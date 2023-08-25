// import React from 'react'
// import { Box, SimpleGrid } from '@chakra-ui/layout'
// import { SubmitHandler, useForm } from 'react-hook-form'
// import { useNavigate, useSearchParams } from 'react-router-dom'
// import {
//   ButtonForm,
//   FormControlNumber,
//   FormControls,
//   FormSelects,
//   Icons,
//   LoadingForm,
//   Modals,
//   PText,
// } from 'ui'
// import { priceService, useSearchs, DataTypes, useQueryParam } from 'api'
// import {
//   Accordion,
//   AccordionItem,
//   AccordionButton,
//   AccordionIcon,
//   AccordionPanel,
//   Input,
//   Text,
// } from '@chakra-ui/react'

// type PriceTypes = DataTypes.PriceTypes.Price
// const ParseDate = (s: string) => {
//   return new Date(s).toISOString().substring(0, 10)
// }

// const PriceDetailPages = () => {
//   const qParam = useQueryParam()
//   const [searchParams] = useSearchParams()
//   const [isLoading, setIsLoading] = React.useState(true)
//   const [strata, setStrata] = React.useState<DataTypes.PriceTypes.Item[]>([
//     { discount: 0, max: 0, min: 0 },
//   ])
//   const navigate = useNavigate()
//   const bySearchProduct = useSearchs<DataTypes.ProductTypes.Product>('product')
//   const bySearchCatPrice = useSearchs<DataTypes.BranchTypes.Branch>('category-price')

//   const { create } = priceService.usePrice()
//   const { data } = priceService.GetPriceeById(String(searchParams.get('priceId')))

//   const {
//     handleSubmit,
//     register,
//     control,
//     setValue,
//     getValues,
//     watch,
//     reset,
//     formState: { errors },
//   } = useForm<PriceTypes>()

//   const setDefault = async () => {
//     const productName = `${data.data?.data.product.name}`
//     const catPriceName = `${data.data?.data.categoryPrice.name}`

//     await bySearchCatPrice(catPriceName).then((i) => {
//       const find = i.find((v) => v.label === catPriceName)
//       setValue('categoryPrice_', find)
//     })

//     await bySearchProduct(productName).then((i) => {
//       const find = i.find((v) => v.label === productName)
//       setValue('product_', find)
//     })

//     setIsLoading(false)
//   }

//   React.useEffect(() => {
//     if (data.isSuccess) {
//       const expiredAt = ParseDate(`${data.data.data.discount.expiredAt}`)
//       reset({
//         ...data.data.data,
//       })
//       setValue('discount.expiredAt', expiredAt)
//       setStrata(data.data.data.discount.items)
//       setDefault()
//     }
//   }, [data.isSuccess])

//   const onClose = () => navigate(`/price?${qParam}`)

//   return (
//     <Modals isOpen={true} setOpen={onClose} size={'3xl'} title='Detail Harga'>
//       {data.isError ? (
//         <PText label={data.error.message} />
//       ) : data.isLoading || isLoading ? (
//         <LoadingForm />
//       ) : (
//         <React.Fragment>
//           <form>
//             <SimpleGrid columns={1} gap={3}>
//               <Box experimental_spaceY={3}>
//                 <FormControls
//                   readOnly
//                   control={control}
//                   label='categoryPrice.name'
//                   register={register}
//                   title={'Kategori Harga'}
//                 />
//                 <FormControlNumber
//                   readOnly
//                   minInput={0}
//                   MIN_LIMIT={1}
//                   control={control}
//                   label='price'
//                   register={register}
//                   title={'Harga'}
//                   errors={errors.price?.message}
//                   required={'Harga tidak boleh kosong'}
//                 />

//                 <FormControls
//                   readOnly
//                   control={control}
//                   type='date'
//                   label='discount.expiredAt'
//                   register={register}
//                   title={'Waktu Expired'}
//                   errors={errors.discount?.expiredAt?.message}
//                   required={'Waktu Expired tidak boleh kosong'}
//                 />
//               </Box>
//               <Accordion allowMultiple mt={4}>
//                 <AccordionItem px={0}>
//                   <h2>
//                     <AccordionButton px={0}>
//                       <Box as='span' flex='1' textAlign='left' fontWeight={500}>
//                         Strata
//                       </Box>
//                       <AccordionIcon />
//                     </AccordionButton>
//                   </h2>
//                   <AccordionPanel pb={4} experimental_spaceY={3} px={0}>
//                     {strata.map((i, idx) => (
//                       <Box key={idx} experimental_spaceY={3}>
//                         <Text>Strata {idx + 1}</Text>
//                         <Box fontWeight={500} experimental_spaceY={2}>
//                           <Text>Diskon</Text>
//                           <Input
//                             readOnly
//                             pattern='[0-9]*'
//                             type={'number'}
//                             value={i.discount}
//                             onChange={(e) => {
//                               const value = e.target.value
//                               setStrata((prev) => {
//                                 const data = [...prev]
//                                 data[idx].discount = Number(value)
//                                 return data
//                               })
//                             }}
//                           />
//                         </Box>

//                         <Box fontWeight={500} experimental_spaceY={2}>
//                           <Text>Mininal</Text>
//                           <Input
//                             readOnly
//                             pattern='[0-9]*'
//                             type={'number'}
//                             value={i.min}
//                             onChange={(e) => {
//                               const value = e.target.value
//                               setStrata((prev) => {
//                                 const data = [...prev]
//                                 data[idx].min = Number(value)
//                                 return data
//                               })
//                             }}
//                           />
//                         </Box>

//                         <Box fontWeight={500} experimental_spaceY={2}>
//                           <Text>Maksimal</Text>
//                           <Input
//                             readOnly
//                             pattern='[0-9]*'
//                             type={'number'}
//                             value={i.max}
//                             onChange={(e) => {
//                               const value = e.target.value
//                               setStrata((prev) => {
//                                 const data = [...prev]
//                                 data[idx].max = Number(value)
//                                 return data
//                               })
//                             }}
//                           />
//                         </Box>
//                       </Box>
//                     ))}
//                   </AccordionPanel>
//                 </AccordionItem>
//               </Accordion>
//             </SimpleGrid>
//           </form>
//         </React.Fragment>
//       )}
//     </Modals>
//   )
// }

// export default PriceDetailPages
