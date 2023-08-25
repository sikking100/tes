import React from 'react'
import { useForm } from 'react-hook-form'
import type { CreatePriceList } from 'apis'
import { priceListService } from 'hooks'
import { ButtonForm, FormControls, LoadingForm, Modals, PText } from 'ui'
import { Box } from '@chakra-ui/layout'
import { disclousureStore } from '~/store'

const PriceListDetailPages: React.FC<{ id: string }> = ({ id }) => {
    const isOpenEdit = disclousureStore((v) => v.isOpenEdit)
    const setIsOpenEdit = disclousureStore((v) => v.setIsOpenEdit)

    const { create } = priceListService.usePriceList()
    const { data, error, isLoading } = priceListService.useGetPriceListById(`${id}`)
    const {
        handleSubmit,
        register,
        reset,
        formState: { errors },
    } = useForm<CreatePriceList>({})

    React.useEffect(() => {
        if (data) reset(data)
    }, [data])

    const onSubmit = async (req: CreatePriceList) => {
        await create.mutateAsync({
            id: req.id,
            name: req.name,
            t: 'update',
        })
        setIsOpenEdit(false)
    }

    return (
        <Modals isOpen={isOpenEdit} setOpen={() => setIsOpenEdit(false)} size={'4xl'} title="Tambah Kategori Harga">
            {error ? (
                <PText label={error} />
            ) : isLoading ? (
                <LoadingForm />
            ) : (
                <form onSubmit={handleSubmit(onSubmit)}>
                    <Box experimental_spaceY={3}>
                        <FormControls isDisabled label="id" register={register} title={'ID'} errors={errors.id?.message} />
                        <FormControls
                            label="name"
                            register={register}
                            title={'Nama'}
                            errors={errors.name?.message}
                            required={'Nama tidak boleh kosong'}
                        />
                    </Box>

                    <ButtonForm label={'Simpan'} isLoading={create.isLoading} onClose={() => setIsOpenEdit(false)} />
                </form>
            )}
        </Modals>
    )
}

export default PriceListDetailPages
