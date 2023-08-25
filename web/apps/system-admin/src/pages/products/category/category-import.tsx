import React from 'react'
import { Table, Tbody, Td, Th, Thead, Tr, TableContainer, Box, HStack, Text, Divider } from '@chakra-ui/react'
import { Buttons, Root, Types, useToast } from 'ui'
import { useNavigate } from 'react-router-dom'
import { Eteam, getCategoryApiInfo } from 'apis'

const dataListProduct: Types.ListSidebarProps[] = [
    {
        id: 1,
        link: '/product',
        title: 'Produk',
    },

    {
        id: 2,
        link: '/import/category',
        title: 'Import Kategori',
    },
    {
        id: 3,
        link: '/brand',
        title: 'Brand',
    },
]

const Wrap: React.FC<{ children: React.ReactNode }> = ({ children }) => (
    <Root appName="System" items={dataListProduct} backUrl={'/product'} activeNum={2}>
        {children}
    </Root>
)

interface ErrorTypes {
    id: string
    error: string
}

interface CreateCategoryImport {
    id: string
    nama: string
    tim: string
    target: string
}

const CategoryImportPages = () => {
    const navigate = useNavigate()
    const [loading, setLoading] = React.useState(false)
    const toast = useToast()
    const [errors, setErrors] = React.useState<ErrorTypes[]>([])
    const [dataFailed, setDataFailed] = React.useState<CreateCategoryImport[]>([])
    const [data, setData] = React.useState<CreateCategoryImport[]>([])

    const headerRow: string[] = ['ID', 'Nama', 'Tim', 'Target']

    React.useEffect(() => {
        const dataLocal = localStorage.getItem('category-import')
        const dataParse = JSON.parse(String(dataLocal)) as CreateCategoryImport[]
        const data = dataParse.splice(0, dataParse.length - 1)
        setData(data)
    }, [])

    const handleSubmit = async () => {
        const errData: ErrorTypes[] = []
        const dataImportFailed: CreateCategoryImport[] = []
        setLoading(true)
        for await (const i of data) {
            try {
                await getCategoryApiInfo().create({
                    id: i.id,
                    name: i.nama,
                    team: i.tim === 'FOOD SERVICE' ? Eteam.FOOD : Eteam.RETAIL,
                    target: Number(i.target),
                })
            } catch (error) {
                const err = error as Error
                errData.push({ id: i.id, error: `${err.message}` })
                dataImportFailed.push(i)
                continue
            }
        }
        setLoading(false)
        if (errData.length > 0) {
            toast({
                status: 'error',
                description: `${errData.length} category gagal diimport, ${errData[0].error}`,
            })
            setDataFailed(dataImportFailed)
            setErrors(errData)
        }
        if (errData.length < 1) {
            toast({
                status: 'success',
                description: 'Import kategori berhasil',
            })
            localStorage.removeItem('category-import')
            navigate('/category', { replace: true })
        }
    }

    return (
        <Wrap>
            <HStack pb={3}>
                <Buttons label="Simpan" onClick={handleSubmit} isLoading={loading} />
            </HStack>
            {errors.length > 0 && (
                <Box my={'10px'}>
                    <Text fontSize={'md'} fontWeight={'semibold'}>
                        List Kateogri Produk Gagal Di Import
                    </Text>
                    <Divider />
                </Box>
            )}

            <Box overflow={'auto'}>
                <TableContainer>
                    <Table size="sm" bg="white" p={4} rounded={'md'}>
                        <Thead height={'40px !important'}>
                            <Tr>
                                {headerRow.map((v, k) => {
                                    return (
                                        <Th key={k} fontSize={'14px !important'}>
                                            {v}
                                        </Th>
                                    )
                                })}
                            </Tr>
                        </Thead>
                        <Tbody>
                            {errors.length > 0 && (
                                <>
                                    {dataFailed.map((i, k) => {
                                        return (
                                            <Tr key={k}>
                                                <Td>{i.id}</Td>
                                                <Td>{i.nama}</Td>
                                                <Td>{i.tim}</Td>
                                                <Td>{i.target}</Td>
                                            </Tr>
                                        )
                                    })}
                                </>
                            )}
                            {errors.length < 1 && (
                                <>
                                    {data.map((i, k) => {
                                        return (
                                            <Tr key={k}>
                                                <Td>{i.id}</Td>
                                                <Td>{i.nama}</Td>
                                                <Td>{i.tim}</Td>
                                                <Td>{i.target}</Td>
                                            </Tr>
                                        )
                                    })}
                                </>
                            )}
                        </Tbody>
                    </Table>
                </TableContainer>
            </Box>
        </Wrap>
    )
}

export default CategoryImportPages
