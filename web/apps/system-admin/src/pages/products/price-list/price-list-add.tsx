import React from 'react'
import { useForm } from 'react-hook-form'
import type { CreatePriceList } from 'apis'
import { priceListService } from 'hooks'
import { ButtonForm, FormControls, Modals } from 'ui'
import { Box } from '@chakra-ui/react'

const PriceListAddPages: React.FC<{
    isOpen: boolean
    setOpen: (v: boolean) => void
}> = ({ isOpen, setOpen }) => {
    const { create } = priceListService.usePriceList()
    const {
        handleSubmit,
        register,
        reset,
        formState: { errors },
    } = useForm<CreatePriceList>({})

    const setClose = () => setOpen(false)

    const onSubmit = async (req: CreatePriceList) => {
        await create.mutateAsync({
            id: req.id,
            name: req.name,
            t: 'create',
        })
        reset()
    }

    return (
        <Modals isOpen={isOpen} setOpen={setClose} size={'4xl'} title="Tambah Kategori Harga">
            <form onSubmit={handleSubmit(onSubmit)}>
                <Box experimental_spaceY={3}>
                    <FormControls
                        label="id"
                        register={register}
                        title={'ID'}
                        errors={errors.name?.message}
                        required={'ID tidak boleh kosong'}
                    />
                    <FormControls
                        label="name"
                        register={register}
                        title={'Nama'}
                        errors={errors.name?.message}
                        required={'Nama tidak boleh kosong'}
                    />
                </Box>
                <ButtonForm label={'Simpan'} isLoading={create.isLoading} onClose={setClose} />
            </form>
        </Modals>
    )
}

export default PriceListAddPages
