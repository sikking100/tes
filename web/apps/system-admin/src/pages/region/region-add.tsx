import { Box } from '@chakra-ui/layout'
import { SubmitHandler, useForm } from 'react-hook-form'
import { ButtonForm, FormControls, Modals, TextWarning } from 'ui'
import { regionService } from 'hooks'
import { CreateRegion } from 'apis'
import { disclousureStore } from '~/store'

const RegionAddPages = () => {
    const { create } = regionService.useRegion()
    const isAdd = disclousureStore((v) => v.isAdd)
    const setOpenAdd = disclousureStore((v) => v.setOpenAdd)

    const {
        handleSubmit,
        register,
        formState: { errors },
    } = useForm<CreateRegion>()

    const onSubmit: SubmitHandler<CreateRegion> = async (data) => {
        await create.mutateAsync({ ...data, t: 'create' })
        setOpenAdd(false)
    }

    return (
        <Modals isOpen={isAdd} setOpen={() => setOpenAdd(false)} size={'3xl'} title="Tambah Region">
            <form onSubmit={handleSubmit(onSubmit)}>
                <Box experimental_spaceY={2}>
                    <FormControls
                        label="id"
                        register={register}
                        title={'ID'}
                        errors={errors.id?.message}
                        required={'ID tidak boleh kosong'}
                    />
                    <TextWarning />

                    <FormControls
                        label="name"
                        register={register}
                        title={'Nama'}
                        errors={errors.name?.message}
                        required={'Nama tidak boleh kosong'}
                    />
                </Box>
                <ButtonForm label={'Simpan'} isLoading={create.isLoading} onClose={() => setOpenAdd(false)} />
            </form>
        </Modals>
    )
}

export default RegionAddPages
