import React from 'react'
import {
    Popover,
    PopoverTrigger,
    IconButton,
    Portal,
    PopoverContent,
    PopoverHeader,
    PopoverCloseButton,
    PopoverBody,
    Tooltip,
    VStack,
} from '@chakra-ui/react'
import queryString from 'query-string'
import { useForm } from 'react-hook-form'
import { Icons, FormSelects, ButtonForm, entity } from 'ui'
import { useNavigate } from 'react-router-dom'
import { Branch, Eroles, SelectsTypes } from 'apis'
import { brandService, categoryService, employeeService } from 'hooks'
import { searchs } from './function'

interface ReqTypes {
    team: SelectsTypes
    branch: SelectsTypes
    category: SelectsTypes
    brand: SelectsTypes
    sales: SelectsTypes
}

export const TYPE_TEAM = [
    { value: entity.Team.FOOD_SERVICE, label: 'Food Service' },
    { value: entity.Team.RETAIL, label: 'Retail' },
]

const FilterProduct: React.FC<{
    isOpen: boolean
    onOpen: React.Dispatch<React.SetStateAction<boolean>>
}> = (props) => {
    const navigate = useNavigate()
    const { isOpen, onOpen } = props
    const { control, getValues } = useForm<ReqTypes>()
    const branch = searchs('branch')
    const { data: category } = categoryService.useGetCategory()
    const { data: brand } = brandService.useGetBrand()
    const { data: sales } = employeeService.useGetEmployee({ query: `${Eroles.SALES}` })

    const onSubmit = () => {
        let branch = ''
        let brand = ''
        let category = ''
        let team = ''
        let sales = ''

        if (getValues('branch.value')) {
            branch = getValues('branch.value')
        }

        if (getValues('brand.value')) {
            brand = getValues('brand.value')
        }

        if (getValues('category.value')) {
            category = getValues('category.value')
        }

        if (getValues('team.value')) {
            team = getValues('team.value')
        }

        if (getValues('sales.value')) {
            sales = getValues('sales.value')
        }

        const query = queryString.stringify(
            {
                branchId: branch,
                brandId: brand,
                categoryId: category,
                team: team,
                salesId: sales,
            },
            {
                skipEmptyString: true,
                skipNull: true,
            }
        )

        navigate(`/product?${query}`)
        onOpen(false)
    }

    const onSearch = async (e: string) => {
        const v = await branch(e)

        const nMap = v.map((i) => {
            const parse = JSON.parse(i.value) as Branch
            return {
                value: parse.id,
                label: parse.name,
            }
        })
        return nMap
    }

    return (
        <Popover isOpen={isOpen} onOpen={() => onOpen(true)} onClose={() => onOpen(false)} placement="bottom" size={'xl'}>
            <>
                <PopoverTrigger>
                    <Tooltip label="Filter">
                        <IconButton
                            onClick={() => onOpen(true)}
                            bg="red.200"
                            aria-label="select date"
                            icon={<Icons.IconFilter color={'#fff'} />}
                            mt={'-10px !important'}
                        />
                    </Tooltip>
                </PopoverTrigger>
                <Portal>
                    <PopoverContent w={'500px'}>
                        <PopoverHeader fontWeight={'semibold'}>Filter Data Produk</PopoverHeader>
                        <PopoverCloseButton />
                        <PopoverBody>
                            <VStack align={'stretch'} w={'full'}>
                                <FormSelects
                                    async={true}
                                    control={control}
                                    label={'branch'}
                                    loadOptions={onSearch}
                                    placeholder={'Pilih Cabang'}
                                    title={'Cabang'}
                                />

                                <FormSelects
                                    control={control}
                                    label={'team'}
                                    options={TYPE_TEAM}
                                    placeholder={'Pilih Jenis Produk'}
                                    title={'Jenis Produk'}
                                />

                                <FormSelects
                                    control={control}
                                    label={'category'}
                                    options={category?.map((v) => ({
                                        value: `${v.id}`,
                                        label: `${v.name}, ${entity.team(String(v.team))}`,
                                    }))}
                                    placeholder={'Pilih Kategori Produk'}
                                    title={'Kategori Produk'}
                                />

                                <FormSelects
                                    control={control}
                                    label={'sales'}
                                    options={sales?.items?.map((v) => ({
                                        value: `${v.id}`,
                                        label: `${v.name}`,
                                    }))}
                                    placeholder={'Pilih Sales'}
                                    title={'Sales'}
                                />

                                <FormSelects
                                    control={control}
                                    label={'brand'}
                                    options={brand?.map((v) => ({
                                        value: `${v.id}`,
                                        label: v.name,
                                    }))}
                                    placeholder={'Pilih Brand'}
                                    title={'Brand'}
                                />
                            </VStack>
                            <ButtonForm type="button" isLoading={false} label="Filter" onClick={onSubmit} onClose={() => onOpen(false)} />
                        </PopoverBody>
                    </PopoverContent>
                </Portal>
            </>
        </Popover>
    )
}

export default FilterProduct
