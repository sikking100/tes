import React from 'react'
import { Table, Tbody, Td, Th, Thead, Tr, TableContainer, Box, HStack } from '@chakra-ui/react'
import { Buttons, Root, useToast } from 'ui'
import { useNavigate } from 'react-router-dom'
import { getBrandApiInfo } from 'apis'
import { dataListProduct } from '~/navigation'

interface BrandImport {
    id: string
    nama: string
}

const Wrap: React.FC<{ children: React.ReactNode }> = ({ children }) => (
    <Root appName="System" items={dataListProduct} backUrl={'/product'} activeNum={3}>
        {children}
    </Root>
)

interface ErrorTypes {
    id: string
    error: string
}

const BrandImportPages = () => {
    const navigate = useNavigate()
    const [loading, setLoading] = React.useState(false)
    const toast = useToast()

    const [errors, setErrors] = React.useState<ErrorTypes[]>([])
    const [dataFailed, setDataFailed] = React.useState<BrandImport[]>([])
    const [data, setData] = React.useState<BrandImport[]>([])

    const headerRow: string[] = ['ID', 'Nama']

    React.useEffect(() => {
        const dataLocal = localStorage.getItem('brand-import')
        const dataParse = JSON.parse(String(dataLocal)) as BrandImport[]
        const data = dataParse.splice(0, dataParse.length - 1)
        setData(data)
    }, [])

    const handleSubmit = async () => {
        const errData: ErrorTypes[] = []
        const dFailed: BrandImport[] = []
        setLoading(true)
        for await (const i of data) {
            try {
                await getBrandApiInfo().create({
                    name: i.nama,
                    id: i.id,
                })
            } catch (error) {
                const err = error as Error
                errData.push({ id: i.id, error: `${err.message}` })
                dFailed.push(i)
                continue
            }
        }
        setLoading(false)
        if (errData.length > 0) {
            toast({
                status: 'error',
                description: `${errData.length} brand gagal diimport`,
            })
            setDataFailed(dFailed)
            setErrors(errData)
        }
        if (errData.length < 1) {
            toast({
                status: 'success',
                description: 'Berhasil import brand',
            })
            navigate('/brand', { replace: true })
        }
    }

    return (
        <Wrap>
            <HStack pb={3}>
                <Buttons label="Simpan" onClick={handleSubmit} isLoading={loading} />
            </HStack>
            <Box minH={'83vh'} maxH={'83vh'} overflow={'auto'}>
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
                        </Tbody>
                    </Table>
                </TableContainer>
            </Box>
        </Wrap>
    )
}

export default BrandImportPages
