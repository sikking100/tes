import React from 'react'
import { Table, Tbody, Td, Th, Thead, Tr, TableContainer, Box, HStack, Text, Divider } from '@chakra-ui/react'
import { Buttons, Root, useToast } from 'ui'
import { useNavigate } from 'react-router-dom'
import { getRegionApiInfo } from 'apis'
import { dataListLocation } from '~/navigation'

interface RegionImport {
    id: string
    nama: string
}
interface ErrorTypes {
    id: string
    error: string
}

const Wrap: React.FC<{ children: React.ReactNode }> = ({ children }) => (
    <Root appName="System" items={dataListLocation} backUrl={'/region'} activeNum={1}>
        {children}
    </Root>
)

const RegionImportPreviewPages = () => {
    const navigate = useNavigate()
    const [isLoading, setLoading] = React.useState(false)
    const [data, setData] = React.useState<RegionImport[]>([])
    const [dataFailed, setDataFailed] = React.useState<RegionImport[]>([])
    const [errors, setErrors] = React.useState<ErrorTypes[]>([])
    const toast = useToast()

    const headerRow: string[] = ['ID', 'Nama']

    React.useEffect(() => {
        const dataLocal = localStorage.getItem('region-import')
        const dataParse = JSON.parse(String(dataLocal)) as RegionImport[]
        const data = dataParse.splice(0, dataParse.length - 1)

        setData(data)
    }, [])

    const handleSubmit = async () => {
        setLoading(true)
        const errData: ErrorTypes[] = []
        const dataImportFailed: RegionImport[] = []
        for await (const i of data) {
            try {
                await getRegionApiInfo().create({
                    id: i.id,
                    name: i.nama,
                })
            } catch (error) {
                const err = error as Error
                errData.push({ id: i.id, error: err.message })
                dataImportFailed.push(i)
                continue
            }
        }
        setLoading(false)

        if (errData.length > 0) {
            toast({
                status: 'error',
                description: `${errData.length} Region gagal diimport, ${errData[0].error}`,
            })
            setDataFailed(dataImportFailed)
            setErrors(errData)
        }
        if (errData.length < 1) {
            toast({
                status: 'success',
                description: 'Import Region Harga berhasil',
            })
            localStorage.removeItem('region-import')
            navigate('/region', { replace: true })
        }
    }

    return (
        <Wrap>
            <HStack pb={3}>
                <Buttons label="Simpan" onClick={handleSubmit} isLoading={isLoading} />
            </HStack>
            {errors.length > 0 && (
                <Box my={'10px'}>
                    <Text fontSize={'md'} fontWeight={'semibold'}>
                        List Region Gagal Di Import
                    </Text>
                    <Divider />
                </Box>
            )}
            <Box minH={'83vh'} maxH={'83vh'} overflow={'auto'}>
                <TableContainer>
                    <Table size="md" bg="white" rounded={'md'}>
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

export default RegionImportPreviewPages
