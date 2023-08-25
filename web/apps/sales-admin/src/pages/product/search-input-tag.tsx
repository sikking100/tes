// import { HStack } from '@chakra-ui/layout'
// import { ButtonIcons, Icons, SearchInput } from 'ui'

// export const SearchInputInTag: React.FC<{
//     setQ: React.Dispatch<React.SetStateAction<string>>
//     setOpenBranch: React.Dispatch<React.SetStateAction<boolean>>
//     label: string
//     roles?: number
// }> = ({ setQ, setOpenBranch, label, roles }) => {
//     return (
//         <HStack w={'fit-content'}>
//             <SearchInput placeholder={label} onChange={(e) => setQ(e.target.value)} />
//             {roles === 3 ? (
//                 <ButtonIcons
//                     bg={'red.200'}
//                     aria-label="Search database"
//                     icon={<Icons.IconFilter color={'#fff'} />}
//                     onClick={() => setOpenBranch(true)}
//                     mt={'-10px !important'}
//                 />
//             ) : null}
//         </HStack>
//     )
// }
