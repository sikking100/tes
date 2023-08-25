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
import { Code, OrderStatus, SelectsTypes } from 'apis'
import { codeSearch } from './function'

interface ReqTypes {
    code: SelectsTypes
    status: SelectsTypes
}

export const TYPE_TEAM = [
    { value: entity.Team.FOOD_SERVICE, label: 'Food Service' },
    { value: entity.Team.RETAIL, label: 'Retail' },
]

const FilterOrder: React.FC<{
    isOpen: boolean
    onOpen: React.Dispatch<React.SetStateAction<boolean>>
    mt?: string
}> = (props) => {
    const navigate = useNavigate()
    const { isOpen, onOpen } = props
    const { control, getValues } = useForm<ReqTypes>()
    const codeSearchs = codeSearch()
    const statusOrder: SelectsTypes[] = [
        {
            value: `${OrderStatus.APPLY}`,
            label: 'MENUNGGU PERSETUJUAN',
        },
        {
            value: `${OrderStatus.PENDING}`,
            label: 'PENDING',
        },
        {
            value: `${OrderStatus.COMPLETE}`,
            label: 'SELESAI',
        },
        {
            value: `${OrderStatus.CANCEL}`,
            label: 'BATAL',
        },
    ]

    const onSubmit = () => {
        let status = ''
        let code = ''

        if (getValues('status.value')) {
            status = getValues('status.value')
        }

        if (getValues('code.value')) {
            const v = JSON.parse(`${getValues('code.value')}`) as Code
            code = v.id
        }

        const query = queryString.stringify(
            {
                code,
                status: status,
            },
            {
                skipEmptyString: true,
                skipNull: true,
            }
        )

        navigate(`/order?${query}`)
        onOpen(false)
    }

    return (
        <Popover isOpen={isOpen} onOpen={() => onOpen(true)} onClose={() => onOpen(false)} placement="bottom" size={'xl'}>
            <>
                <PopoverTrigger>
                    <Tooltip label="Filter">
                        <IconButton
                            onClick={() => onOpen(true)}
                            bg="red.200"
                            aria-label="select filter-order"
                            icon={<Icons.IconFilter color={'#fff'} />}
                            mt={props.mt || '-10px !important'}
                        />
                    </Tooltip>
                </PopoverTrigger>
                <Portal>
                    <PopoverContent w={'500px'}>
                        <PopoverHeader fontWeight={'semibold'}>Filter Order</PopoverHeader>
                        <PopoverCloseButton />
                        <PopoverBody>
                            <VStack align={'stretch'} w={'full'}>
                                <FormSelects
                                    async={true}
                                    control={control}
                                    label={'code'}
                                    loadOptions={codeSearchs}
                                    placeholder={'Pilih Kode'}
                                    title={'Kode'}
                                />

                                <FormSelects
                                    control={control}
                                    label={'status'}
                                    options={statusOrder}
                                    placeholder={'Pilih Status Pesanan'}
                                    title={'Status Pesanan'}
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

export default FilterOrder
