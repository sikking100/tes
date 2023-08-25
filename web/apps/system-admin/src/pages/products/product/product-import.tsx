import React from 'react'
import { Table, Tbody, Td, Th, Thead, Tr, TableContainer, Box, HStack, Text, Divider } from '@chakra-ui/react'
import { Buttons, Root, useToast } from 'ui'
import { useNavigate } from 'react-router-dom'
import { dataListProduct } from '~/navigation'
import { getProdcutApiInfo } from 'apis'
import { brandService, categoryService } from 'hooks'

const Wrap: React.FC<{ children: React.ReactNode }> = ({ children }) => (
    <Root appName="System" items={dataListProduct} backUrl={'/product'} activeNum={1}>
        {children}
    </Root>
)

interface ErrorTypes {
    id: string
    error: string
}

interface ProductTypesCreate {
    id: string
    nama: string
    deskripsi: string
    ukuran: string
    point: number
    categoryId: string
    brandId: string
}

const ProductImportPages = () => {
    const navigate = useNavigate()
    const [loading, setLoading] = React.useState(false)
    const toast = useToast()
    const [errors, setErrors] = React.useState<ErrorTypes[]>([])
    const [dataProductFailed, setDataProductFailed] = React.useState<ProductTypesCreate[]>([])
    const [data, setData] = React.useState<ProductTypesCreate[]>([])
    const { data: dataBrand } = brandService.useGetBrand()
    const { data: dataCategory } = categoryService.useGetCategory()

    const headerRow: string[] = ['ID', 'Nama', 'Ukuran', 'Kategori ID', 'Brand ID', 'Point']

    React.useEffect(() => {
        const dataLocal = localStorage.getItem('product-import')
        const dataParse = JSON.parse(String(dataLocal)) as ProductTypesCreate[]
        const data = dataParse.splice(0, dataParse.length - 1)
        setData(data)
    }, [])

    const handleSubmit = async () => {
        const errData: ErrorTypes[] = []
        const dataErrorImport: ProductTypesCreate[] = []
        setLoading(true)
        for await (const i of data) {
            try {
                const brand = dataBrand?.find((v) => v.id === i.brandId)
                const category = dataCategory?.find((v) => v.id === i.categoryId)
                if (brand && category) {
                    await getProdcutApiInfo().create({
                        brand: brand,
                        category: category,
                        point: Number(i.point),
                        id: i.id,
                        name: i.nama,
                        size: i.ukuran,
                        description: i.deskripsi,
                    })
                }
            } catch (error) {
                const err = error as Error
                errData.push({ id: i.id, error: `${err.message}` })
                dataErrorImport.push(i)
                continue
            }
        }
        setLoading(false)
        if (errData.length > 0) {
            toast({
                status: 'warning',
                description: `${errData.length} produk gagal diimport, ${errData[0].error}`,
            })
            setErrors(errData)
            setDataProductFailed(dataErrorImport)
        }
        if (errData.length < 1) {
            toast({
                status: 'success',
                description: 'Import produk berhasil',
            })
            localStorage.removeItem('product-import')
            navigate('/product', { replace: true })
        }
    }

    return (
        <Wrap>
            <HStack pb={3}>
                <Buttons label="Simpan" onClick={handleSubmit} isLoading={loading} w={'150px'} />
            </HStack>
            {errors.length > 0 && (
                <Box my={'10px'}>
                    <Text fontSize={'md'} fontWeight={'semibold'}>
                        List Produk Gagal Di Import
                    </Text>
                    <Divider />
                </Box>
            )}
            <Box>
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
                            <>
                                {errors.length < 1 && (
                                    <>
                                        {data.map((i, k) => {
                                            return (
                                                <Tr key={k}>
                                                    <Td>{i.id}</Td>
                                                    <Td>{i.nama}</Td>
                                                    <Td>{i.ukuran}</Td>
                                                    <Td>{i.categoryId}</Td>
                                                    <Td>{i.brandId}</Td>
                                                    <Td>{i.point}</Td>
                                                </Tr>
                                            )
                                        })}
                                    </>
                                )}

                                {errors.length > 0 && (
                                    <>
                                        {dataProductFailed.map((i, k) => {
                                            return (
                                                <Tr key={k}>
                                                    <Td>{i.id}</Td>
                                                    <Td>{i.nama}</Td>
                                                    <Td>{i.ukuran}</Td>
                                                    <Td>{i.categoryId}</Td>
                                                    <Td>{i.brandId}</Td>
                                                    <Td>{i.point}</Td>
                                                </Tr>
                                            )
                                        })}
                                    </>
                                )}
                            </>
                        </Tbody>
                    </Table>
                </TableContainer>
            </Box>
        </Wrap>
    )
}

export default ProductImportPages
