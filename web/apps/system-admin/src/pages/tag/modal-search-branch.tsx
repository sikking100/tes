import React from 'react'
import { SearchIcon, ChevronRightIcon } from '@chakra-ui/icons'
import {
    InputGroup,
    InputLeftElement,
    Input,
    Divider,
    Skeleton,
    Center,
    Container,
    InputRightElement,
    Box,
    HStack,
    IconButton,
    InputProps,
    Tooltip,
} from '@chakra-ui/react'
import { createSearchParams, useNavigate, useSearchParams } from 'react-router-dom'
import { Icons, Modals, SearchInput } from 'ui'
import { branchService } from 'hooks'

export const ListSearch: React.FC<{
    onClick?: React.MouseEventHandler<HTMLDivElement> | undefined
    inputProps?: InputProps
}> = ({ onClick, inputProps }) => {
    return (
        <Box
            fontSize="md"
            rounded="xl"
            h="50px"
            bg="gray.100"
            _hover={{ bg: 'red.200', color: 'white', cursor: 'pointer' }}
            onClick={onClick}
        >
            <Center h="100%">
                <Container maxW="container.xl">
                    <InputGroup _hover={{ color: 'white' }}>
                        <Input
                            isReadOnly
                            variant="unstyled"
                            _hover={{ cursor: 'pointer' }}
                            fontWeight="bold"
                            fontSize={'sm'}
                            {...inputProps}
                        />
                        <InputRightElement h="100%">
                            <ChevronRightIcon color="currentcolor" />
                        </InputRightElement>
                    </InputGroup>
                </Container>
            </Center>
        </Box>
    )
}

const ModalsSelectBranch: React.FC<{
    isOpenBranch: boolean
    setOpenBranch: React.Dispatch<React.SetStateAction<boolean>>
}> = ({ isOpenBranch, setOpenBranch }) => {
    const [loadings, setLoadings] = React.useState(true)
    const navigate = useNavigate()
    const [searchParams] = useSearchParams()

    const { data, setQ, setLimit, isLoading } = branchService.useGetBranch()

    React.useEffect(() => {
        setLimit(5)
        if (searchParams.get('branchId')) setOpenBranch(false)
        setLoadings(false)
    }, [])

    if (loadings) return <></>

    return (
        <Modals isOpen={isOpenBranch} setOpen={() => setOpenBranch(false)} title="Pilih Cabang">
            <InputGroup>
                <InputLeftElement pointerEvents="none">
                    <SearchIcon color="gray.300" />
                </InputLeftElement>
                <Input type="tel" placeholder="Ketik nama cabang" onChange={(e) => setQ(e.target.value)} />
            </InputGroup>
            <Divider mt="5px" />
            <Box maxH={data ? 'full' : '60vh'} minH={data ? 'full' : '60vh'} overflow="auto" mt="10px">
                {isLoading ? (
                    <Skeleton h={'50px'} />
                ) : (
                    <Box experimental_spaceY={3}>
                        {data.items?.map((it, id) => (
                            <ListSearch
                                key={id}
                                inputProps={{ value: it.name }}
                                onClick={() => {
                                    navigate({
                                        search: createSearchParams({
                                            branchId: it.id,
                                        }).toString(),
                                    })
                                    setOpenBranch(false)
                                }}
                            />
                        ))}
                    </Box>
                )}
            </Box>
        </Modals>
    )
}

export default ModalsSelectBranch

export const SearchInputInTag: React.FC<{
    prefix: string
    label: string
    setQ: React.Dispatch<React.SetStateAction<string>>
    setOpenBranch?: React.Dispatch<React.SetStateAction<boolean>>
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    onClickBtnExp?: ((i: any[]) => void) | undefined
}> = ({ prefix, setQ, setOpenBranch, label, onClickBtnExp }) => {
    return (
        <HStack w={'fit-content'}>
            {label !== 'History' && (
                <>
                    {prefix === 'warehouse' ? (
                        <SearchInput placeholder={`Cari ${label}`} onChange={(e) => setQ(e.target.value)} />
                    ) : prefix === 'qty-history' ? (
                        <SearchInput placeholder={`Cari ${label}`} onChange={(e) => setQ(e.target.value)} />
                    ) : (
                        <SearchInput
                            labelBtn={`Tambah ${label}`}
                            link={`/${prefix}/add`}
                            placeholder={`Cari ${label}`}
                            onChange={(e) => setQ(e.target.value)}
                            onClickBtnExp={onClickBtnExp}
                        />
                    )}
                </>
            )}

            {setOpenBranch && (
                <Tooltip label="Pilih Cabang">
                    <IconButton
                        bg={'red.200'}
                        aria-label="Search database"
                        icon={<Icons.IconFilter color={'#fff'} />}
                        onClick={() => setOpenBranch(true)}
                        mt={'-10px !important'}
                    />
                </Tooltip>
            )}
        </HStack>
    )
}
