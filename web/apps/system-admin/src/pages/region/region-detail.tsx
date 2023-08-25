import React from 'react'
import { Box } from '@chakra-ui/layout'
import { SubmitHandler, useForm } from 'react-hook-form'
import { ButtonForm, FormControls, LoadingForm, Modals, PText } from 'ui'
import { regionService } from 'hooks'
import type { Region } from 'apis'
import { disclousureStore } from '~/store'

const RegionDetailPages: React.FC<{ id: string }> = ({ id }) => {
    const { create } = regionService.useRegion()
    const { data, error, isLoading } = regionService.useGetRegionById(String(id))
    const setIsOpenEdit = disclousureStore((v) => v.setIsOpenEdit)
    const isOpenEdit = disclousureStore((v) => v.isOpenEdit)

    const {
        handleSubmit,
        register,
        formState: { errors },
        reset,
    } = useForm<Region>()

    React.useEffect(() => {
        if (data) {
            reset(data)
        }
    }, [data])

    const onSubmit: SubmitHandler<Region> = async (data) => {
        await create.mutateAsync({ ...data, t: 'update' })
        setIsOpenEdit(false)
    }

    return (
        <Modals isOpen={isOpenEdit} setOpen={() => setIsOpenEdit(false)} size={'2xl'} title="Detail Region">
            {error ? (
                <PText label={error} />
            ) : isLoading ? (
                <LoadingForm />
            ) : (
                <React.Fragment>
                    <form onSubmit={handleSubmit(onSubmit)}>
                        <Box experimental_spaceY={2}>
                            <FormControls
                                isDisabled
                                label="id"
                                register={register}
                                title={'ID'}
                                errors={errors.id?.message}
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
                        <ButtonForm label={'Simpan'} isLoading={create.isLoading} onClose={() => setIsOpenEdit(false)} />
                    </form>
                </React.Fragment>
            )}
        </Modals>
    )
}

export default RegionDetailPages
