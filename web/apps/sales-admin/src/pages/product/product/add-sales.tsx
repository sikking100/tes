import React from 'react'
import { Avatar, Box, Divider, HStack, SimpleGrid, Skeleton, Text, VStack } from '@chakra-ui/react'
import { Employee, Eroles, ProductTypes, SelectsTypes } from 'apis'
import { employeeService, productService } from 'hooks'
import { useForm } from 'react-hook-form'
import { ButtonForm, FormSelects, Modals, entity } from 'ui'
import { searchs } from './function'

type TUpdateSales = ProductTypes.UpdateSalesProduct & {
    sales_: SelectsTypes
    branch_: SelectsTypes
    team_: SelectsTypes
}

const AddSales: React.FC<{ isOpen: boolean; setOpen: (v: boolean) => void; product: ProductTypes.Product }> = ({
    isOpen,
    product,
    setOpen,
}) => {
    const {
        control,
        handleSubmit,
        setValue,
        formState: { errors },
        getValues,
    } = useForm<TUpdateSales>()
    const { updateProductSales } = productService.useProductSales()
    const [isLoading, setLoading] = React.useState(true)
    const { data, setLimit } = employeeService.useGetEmployee({
        query: `${Eroles.SALES},${product.branchId}`,
    })
    const search = searchs('sales')

    const setDefault = async () => {
        const find = await search(product.salesName, product.branchId)
        find.forEach((v) => {
            const sales = JSON.parse(v.value) as Employee
            if (sales.id === product.salesId) {
                setValue('sales_', {
                    value: v.value,
                    label: v.label,
                })
            }
        })
        setLoading(false)
    }

    React.useEffect(() => {
        setLimit(80)
        setDefault()
    }, [])

    const setClose = () => setOpen(false)

    const onSubmit = async (req: TUpdateSales) => {
        let pSales: Employee | null = null
        let salesId = ''
        let salesName = ''
        let salesTeam: number | null = null

        if (req.sales_) {
            pSales = JSON.parse(req.sales_.value) as Employee
            salesId = pSales.id
            salesName = pSales.name
            salesTeam = pSales.team
        }
        const ReqData: ProductTypes.UpdateSalesProduct = {
            id: product.id,
            branchId: product.branchId,
            brandId: product.brand.id,
            categoryId: product.category.id,
            team: salesTeam as number,
            salesId: salesId,
            salesName: salesName,
        }
        await updateProductSales.mutateAsync(ReqData)
        setClose()
    }

    return (
        <Modals isOpen={isOpen} setOpen={setClose} title="Tambah Sales" size="4xl">
            <HStack mb={'10px'}>
                <HStack align={'start'} w={'full'}>
                    <Avatar src={product.imageUrl} boxSize={'100px'} rounded={'fukk'} />
                    <SimpleGrid columns={2} gap={4} w="full">
                        <VStack align={'start'} spacing={1} w={'full'}>
                            <Box>
                                <Text fontSize={'sm'} fontWeight={'bold'}>
                                    Nama Produk
                                </Text>
                                <Text fontSize={'lg'}>{product.name}</Text>
                            </Box>
                            <Divider />
                            <Box>
                                <Text fontSize={'sm'} fontWeight={'bold'}>
                                    Kategori
                                </Text>
                                <Text>
                                    {product.category.name} - {entity.team(String(product.category.team))}
                                </Text>
                            </Box>

                            <Divider />
                            <Box>
                                <Text fontSize={'sm'} fontWeight={'bold'}>
                                    Brand
                                </Text>
                                <Text>{product.brand.name}</Text>
                            </Box>
                            <Divider />
                        </VStack>
                        <VStack align={'start'} spacing={1} w={'full'}>
                            <Box>
                                <Text fontSize={'sm'} fontWeight={'bold'}>
                                    Poin
                                </Text>
                                <Text fontSize={'lg'}>{product.point}</Text>
                            </Box>
                            <Divider />
                            <Box>
                                <Text fontSize={'sm'} fontWeight={'bold'}>
                                    Ukuran
                                </Text>
                                <Text>{product.size}</Text>
                            </Box>

                            <Divider />
                        </VStack>
                    </SimpleGrid>
                </HStack>
            </HStack>
            <form onSubmit={handleSubmit(onSubmit)}>
                {isLoading && <Skeleton w={'full'} height={'40px'} />}
                {!isLoading && (
                    <FormSelects
                        control={control}
                        label="sales_"
                        defaultValue={getValues('sales_')}
                        options={data?.items.map((v) => ({
                            value: JSON.stringify(v),
                            label: v.name,
                            image: v.imageUrl,
                        }))}
                        title="Pilih Sales"
                        placeholder="Pilih Sales"
                        errors={errors.sales_?.message}
                    />
                )}

                <ButtonForm label="Simpan" onClose={setClose} isLoading={updateProductSales.isLoading} />
            </form>
        </Modals>
    )
}

export default AddSales
