import React from 'react'
import { Table, Tbody, Td, Th, Thead, Tr, TableContainer, Box, HStack, Text, Divider } from '@chakra-ui/react'
import { Buttons, Root, Types, useToast } from 'ui'
import { useNavigate } from 'react-router-dom'
import { getBranchApiInfo } from 'apis'

export interface BranchRequest {
    id: string
    nama: string
    alamat: string
    regionId: string
    regionName: string
    latitude: string
    longitude: string
}
interface ErrorTypes {
    id: string
    error: string
}

const dataListLocation: Types.ListSidebarProps[] = [
    {
        id: 1,
        link: '/branch-import',
        title: 'Cabang Import',
    },
]

const Wrap: React.FC<{ children: React.ReactNode }> = ({ children }) => (
    <Root appName="System" items={dataListLocation} backUrl={'/branch'} activeNum={1}>
        {children}
    </Root>
)

const BranchImportPreviewPages = () => {
    const navigate = useNavigate()
    const [isLoading, setLoading] = React.useState(false)
    const [data, setData] = React.useState<BranchRequest[]>([])
    const [dataFailed, setDataFailed] = React.useState<BranchRequest[]>([])
    const [errors, setErrors] = React.useState<ErrorTypes[]>([])
    const toast = useToast()

    const headerRow: string[] = ['ID', 'Nama', 'ID Region', 'Nama Region', 'Alamat', 'Latitude', 'Longitude']

    React.useEffect(() => {
        const dataLocal = localStorage.getItem('branch-import')
        const dataParse = JSON.parse(String(dataLocal)) as BranchRequest[]
        const data = dataParse.splice(0, dataParse.length - 1)
        setData(data)
    }, [])

    const handleSubmit = async () => {
        setLoading(true)
        const errData: ErrorTypes[] = []
        const dataImportFailed: BranchRequest[] = []
        for await (const i of data) {
            try {
                await getBranchApiInfo().create({
                    id: i.id,
                    name: i.nama,
                    address: i.alamat,
                    regionId: i.regionId,
                    regionName: i.regionName,
                    addressLat: Number(i.latitude),
                    addressLng: Number(i.longitude),
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
                description: `${errData.length} Cabang gagal diimport, ${errData[0].error}`,
            })
            setDataFailed(dataImportFailed)
            setErrors(errData)
        }
        if (errData.length < 1) {
            toast({
                status: 'success',
                description: 'Import Cabang Harga berhasil',
            })
            localStorage.removeItem('branch-import')
            navigate('/branch', { replace: true })
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
                        List Cabang Gagal Di Import
                    </Text>
                    <Divider />
                </Box>
            )}

            <Box minH={'83vh'} maxH={'83vh'} overflow={'auto'}>
                <TableContainer>
                    <Table size="md" bg="white" rounded={'md'}>
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
                                                <Td>{i.regionId}</Td>
                                                <Td>{i.regionName}</Td>
                                                <Td>{i.alamat}</Td>
                                                <Td>{i.latitude}</Td>
                                                <Td>{i.longitude}</Td>
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
                                                <Td>{i.regionId}</Td>
                                                <Td>{i.regionName}</Td>
                                                <Td>{i.alamat}</Td>
                                                <Td>{i.latitude}</Td>
                                                <Td>{i.longitude}</Td>
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

export default BranchImportPreviewPages
