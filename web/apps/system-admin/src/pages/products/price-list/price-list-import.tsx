import { Box, Divider, HStack, Table, TableContainer, Tbody, Td, Text, Th, Thead, Tr } from '@chakra-ui/react'
import React from 'react'
import { useNavigate } from 'react-router-dom'
import { Buttons, Root, useToast } from 'ui'
import { dataListProduct } from '~/navigation'
import { getPriceListApiInfo } from 'apis'

interface PriceListProps {
    id: string
    nama: string
}

interface ErrorTypes {
    id: string
    error: string
}

const Wrap: React.FC<{ children: React.ReactNode }> = ({ children }) => (
    <Root appName="System" items={dataListProduct} backUrl={'/price-list'} activeNum={6}>
        {children}
    </Root>
)
const PriceListImportPages = () => {
    const navigate = useNavigate()
    const [loading, setLoading] = React.useState(false)
    const [data, setData] = React.useState<PriceListProps[]>([])
    const [dataFailed, setDataFailed] = React.useState<PriceListProps[]>([])
    const [errors, setErrors] = React.useState<ErrorTypes[]>([])

    const toast = useToast()

    const headerRow: string[] = ['ID', 'Nama']

    React.useEffect(() => {
        const dataLocal = localStorage.getItem('price-list-import')
        const dataParse = JSON.parse(String(dataLocal)) as PriceListProps[]
        const data = dataParse.splice(0, dataParse.length - 1)
        setData(data)
    }, [])

    const handleSubmit = async () => {
        const errData: ErrorTypes[] = []
        const dataImportFailed: PriceListProps[] = []
        setLoading(true)
        for await (const i of data) {
            try {
                await getPriceListApiInfo().create({ id: i.id, name: i.nama })
            } catch (error) {
                errData.push({ id: i.id, error: '1' })
                dataImportFailed.push(i)
                continue
            }
        }
        setLoading(false)
        if (errData.length > 0) {
            toast({
                status: 'error',
                description: `${errData.length} Kategori harga gagal diimport, ${errData[0].error}`,
            })
            setDataFailed(dataImportFailed)
            setErrors(errData)
        }
        if (errData.length < 1) {
            toast({
                status: 'success',
                description: 'Import Kategori Harga berhasil',
            })
            localStorage.removeItem('price-list-import')
            navigate('/price-list', { replace: true })
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
                        List Kateogri Harga Gagal Di Import
                    </Text>
                    <Divider />
                </Box>
            )}
            <Box minH={'83vh'} maxH={'83vh'} overflow={'auto'}>
                <TableContainer>
                    <Table size="sm" bg="white" p={4} rounded={'md'}>
                        <Thead height={'40px !important'}>
                            <Tr>
                                {headerRow.map((v) => {
                                    return (
                                        <Th key={v} fontSize={'14px !important'}>
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

export default PriceListImportPages
