// import React from 'react'
// import { SearchIcon, ChevronRightIcon } from '@chakra-ui/icons'
// import {
//   InputGroup,
//   InputLeftElement,
//   Input,
//   Divider,
//   Skeleton,
//   Center,
//   Container,
//   InputRightElement,
//   Box,
//   Text,
//   HStack,
//   IconButton,
// } from '@chakra-ui/react'
// import { createSearchParams, useNavigate, useSearchParams } from 'react-router-dom'
// import { branchService, useQueryParam } from 'api'
// import { Modals } from './modals'
// import { PText } from './text'

// export const ModalsSelectBranch: React.FC<{
//   isOpenBranch: boolean
//   setOpenBranch: React.Dispatch<React.SetStateAction<boolean>>
// }> = ({ isOpenBranch, setOpenBranch }) => {
//   const [loadings, setLoadings] = React.useState(true)
//   const navigate = useNavigate()
//   const [searchParams] = useSearchParams()

//   const { data, setQ, setLimit } = branchService.useGetBranch({})

//   React.useEffect(() => {
//     setLimit(5)
//     if (searchParams.get('branchId')) setOpenBranch(false)
//     setLoadings(false)
//   }, [])

//   if (loadings) return <></>

//   return (
//     <Modals isOpen={isOpenBranch} setOpen={() => setOpenBranch(false)} title='Pilih Cabang'>
//       <InputGroup>
//         <InputLeftElement pointerEvents='none' children={<SearchIcon color='gray.300' />} />
//         <Input type='tel' placeholder='Ketik nama cabang' onChange={(e) => setQ(e.target.value)} />
//       </InputGroup>
//       <Divider mt='5px' />
//       <Box maxH={data ? 'full' : '60vh'} minH={data ? 'full' : '60vh'} overflow='auto' mt='10px'>
//         {data.isLoading ? (
//           <Skeleton h={'50px'} />
//         ) : (
//           <Box experimental_spaceY={3}>
//             {data.data?.data.items?.map((it, id) => (
//               <Box
//                 key={id}
//                 fontSize='md'
//                 rounded='xl'
//                 h='50px'
//                 bg='gray.100'
//                 _hover={{ bg: 'red.200', color: 'white', cursor: 'pointer' }}
//                 onClick={() => {
//                   navigate({
//                     search: createSearchParams({
//                       branchId: it.id,
//                     }).toString(),
//                   })
//                   setOpenBranch(false)
//                 }}
//               >
//                 <Center h='100%'>
//                   <Container maxW='container.xl'>
//                     <InputGroup _hover={{ color: 'white' }}>
//                       <Input
//                         value={it.name}
//                         isReadOnly
//                         variant='unstyled'
//                         _hover={{ cursor: 'pointer' }}
//                         fontWeight='bold'
//                         fontSize={'sm'}
//                       />
//                       <InputRightElement h='100%'>
//                         <ChevronRightIcon color='currentcolor' />
//                       </InputRightElement>
//                     </InputGroup>
//                   </Container>
//                 </Center>
//               </Box>
//             ))}
//           </Box>
//         )}
//       </Box>
//     </Modals>
//   )
// }

// export const CardDetailBranch: React.FC<{ branchId: string }> = ({ branchId }) => {
//   const { data } = branchService.useGetBranchById(branchId)

//   return (
//     <Box mb={2} bg='white' px={3} py={2} rounded={'xl'}>
//       {data.isError ? (
//         <PText label={data.error.message} />
//       ) : data.isLoading ? (
//         <Text>Loading...</Text>
//       ) : (
//         <React.Fragment>
//           <Box>
//             <Text fontWeight={'semibold'} fontSize={'lg'}>
//               {data.data.data.name}
//             </Text>
//             <Text fontWeight={'semibold'} fontSize={'sm'}>
//               {data.data.data.address.name}
//             </Text>
//           </Box>
//         </React.Fragment>
//       )}
//     </Box>
//   )
// }
export {}
