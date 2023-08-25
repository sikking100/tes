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
} from '@chakra-ui/react'
import React from 'react'
import { useForm } from 'react-hook-form'
import { Icons, FormSelects, ButtonForm } from 'ui'
// import { DataTypes } from 'api'
import { TYPE_TEAM } from '~/utils/roles'
import { useNavigate } from 'react-router-dom'
import { SelectsTypes } from 'apis'

interface ReqTypes {
    team: SelectsTypes
}

const FilterProduct: React.FC<{
    isOpen: boolean
    onOpen: React.Dispatch<React.SetStateAction<boolean>>
}> = (props) => {
    const navigate = useNavigate()
    const { isOpen, onOpen } = props
    const firstFieldRef = React.useRef(null)

    const options: SelectsTypes[] = [{ value: '-', label: 'Semua' }, ...TYPE_TEAM]

    const { control, getValues } = useForm<ReqTypes>()

    const onSubmit = () => {
        if (getValues('team.value') === '-') {
            navigate('/product?team=null')

            onOpen(false)
            return
        }
        navigate(`/product?team=${getValues('team.value')}`)
        onOpen(false)
    }

    return (
        <Popover
            isOpen={isOpen}
            initialFocusRef={firstFieldRef}
            onOpen={() => onOpen(true)}
            onClose={() => onOpen(false)}
            placement="bottom"
            size={'xl'}
        >
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
                            <form>
                                <FormSelects
                                    control={control}
                                    label={'team'}
                                    defaultValue={options[0]}
                                    options={options}
                                    placeholder={'Pilih Jenis Produk'}
                                    title={'Jenis Produk'}
                                />

                                <ButtonForm
                                    type="button"
                                    isLoading={false}
                                    label="Filter"
                                    onClick={onSubmit}
                                    onClose={() => onOpen(false)}
                                />
                            </form>
                        </PopoverBody>
                    </PopoverContent>
                </Portal>
            </>
        </Popover>
    )
}

export default FilterProduct
