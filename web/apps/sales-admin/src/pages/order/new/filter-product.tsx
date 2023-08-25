import {
    Box,
    IconButton,
    Popover,
    PopoverArrow,
    PopoverBody,
    PopoverCloseButton,
    PopoverContent,
    PopoverHeader,
    PopoverTrigger,
} from '@chakra-ui/react'
import { Brand, Eteam, ProductTypes, SelectsTypes } from 'apis'
import { ButtonForm, Icons } from 'ui'
import { brandSearch } from './function'
import { FilterProps } from './types'
import AsyncSelect from 'react-select/async'
import Select from 'react-select'
import React, { useState } from 'react'

const options: SelectsTypes[] = [
    {
        value: '1',
        label: 'Terlaris',
    },
    {
        value: '2',
        label: 'Diskon',
    },
]

const optionsTeam: SelectsTypes[] = [
    {
        value: `${Eteam.FOOD}`,
        label: 'FOOD SERVICE',
    },
    {
        value: `${Eteam.RETAIL}`,
        label: 'RETAIL',
    },
]

export const FilterProduct: React.FC<FilterProps> = ({ isOpen, onOpen, onSetQuerys }) => {
    const brandOptions = brandSearch()
    const [selectedBrand, setSelectedBrand] = useState<string>('')
    const [selectedTeam, setSelectedTeam] = useState<string>('')
    const [selectedType, setSelectedType] = useState<ProductTypes.ESort | undefined>(undefined)

    const onChangeSelect = () => {
        onSetQuerys({
            brandId: selectedBrand,
            sort: selectedType,
            team: selectedTeam,
        })
        onOpen(false)
    }

    return (
        <Popover isOpen={isOpen} onOpen={() => onOpen(true)} onClose={() => onOpen(false)} placement="bottom" size={'xl'}>
            <PopoverTrigger>
                <IconButton bg={'red.200'} aria-label="Search product filter" icon={<Icons.IconFilter color={'#FFF'} />} />
            </PopoverTrigger>
            <PopoverContent w={'400px'}>
                <PopoverArrow />
                <PopoverHeader fontWeight={'bold'}>Filter Produk</PopoverHeader>
                <PopoverCloseButton />
                <PopoverBody>
                    <Box experimental_spaceY={3}>
                        <AsyncSelect
                            loadOptions={brandOptions}
                            placeholder="Pilih Berdasarkan Brand"
                            onChange={(e) => {
                                const value = JSON.parse(`${e?.value}`) as Brand
                                setSelectedBrand(value.id)
                            }}
                        />
                        <Select
                            options={options}
                            placeholder="Pilih Berdasarkan Terlaris atau Diskon"
                            onChange={(e) => {
                                const v = e?.value as unknown as ProductTypes.ESort
                                setSelectedType(v)
                            }}
                        />
                        <Select
                            options={optionsTeam}
                            placeholder="Pilih Berdasarkan Tim"
                            onChange={(e) => {
                                const v = String(e?.value)
                                setSelectedTeam(v)
                            }}
                        />
                        <ButtonForm type="button" isLoading={false} label="Filter" onClick={onChangeSelect} onClose={() => onOpen(false)} />
                    </Box>
                </PopoverBody>
            </PopoverContent>
        </Popover>
    )
}
