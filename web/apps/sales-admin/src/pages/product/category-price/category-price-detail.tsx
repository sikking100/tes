// import React from 'react'
// import { useNavigate, useParams } from 'react-router-dom'
// import { categoryPriceService, DataTypes, useQueryParam } from 'api'
// import { FormControls, LoadingForm, Modals, PText } from 'ui'
// import { useForm } from 'react-hook-form'
// import { Box } from '@chakra-ui/layout'

// type ReqTypes = DataTypes.CategoryPriceTypes.CategoryPrice

// export const TYPE_TEAM = [
//   { value: '-', label: '-' },
//   { value: DataTypes.EmployeeTypes.Team.FOOD_SERVICE, label: 'Food Service' },
//   { value: DataTypes.EmployeeTypes.Team.RETAIL, label: 'Retail' },
// ]

// const CategoryPriceDetailPages = () => {
//   const qParam = useQueryParam()
//   const params = useParams()
//   const navigate = useNavigate()
//   const { data } = categoryPriceService.useCategoryPriceById(String(params.id))

//   const {
//     register,
//     formState: { errors },
//     reset,
//   } = useForm<ReqTypes>({})

//   React.useEffect(() => {
//     if (data.isSuccess) {
//       reset({
//         ...data.data.data,
//         team: data.data.data.team === 1 ? 'Food Service' : ('Retail' as any),
//       })
//     }
//   }, [data.isSuccess])

//   const onClose = () => navigate(`/category-price?${qParam}`, { replace: true })

//   return (
//     <Modals
//       isOpen={true}
//       setOpen={onClose}
//       size={'3xl'}
//       title='Detail Kategori Harga'
//       scrlBehavior='outside'
//     >
//       {data.isError ? (
//         <PText label={data.error.message} />
//       ) : data.isLoading ? (
//         <LoadingForm />
//       ) : (
//         <React.Fragment>
//           <form>
//             <Box experimental_spaceY={3} mb={3}>
//               <FormControls
//                 readOnly
//                 label='id'
//                 register={register}
//                 title={'ID'}
//                 errors={errors.name?.message}
//                 required={'ID tidak boleh kosong'}
//               />
//               <FormControls
//                 readOnly
//                 label='name'
//                 register={register}
//                 title={'Nama'}
//                 errors={errors.name?.message}
//                 required={'Nama tidak boleh kosong'}
//               />
//               <FormControls
//                 readOnly
//                 label='branch.name'
//                 register={register}
//                 title={'Cabang'}
//                 errors={errors.name?.message}
//               />
//               <FormControls
//                 readOnly
//                 label='team'
//                 register={register}
//                 title={'Tim'}
//                 errors={errors.name?.message}
//                 required={'Nama tidak boleh kosong'}
//               />
//             </Box>
//           </form>
//         </React.Fragment>
//       )}
//     </Modals>
//   )
// }

// export default CategoryPriceDetailPages
