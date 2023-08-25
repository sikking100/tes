import { SubmitHandler, useForm } from 'react-hook-form'
import { Modals, FormControls, ButtonForm, TextWarning, FormSelects } from 'ui'
// import { DataTypes, productCategoryService } from 'api'
import { categoryService } from 'hooks'
import type { CreateCategory, SelectsTypes } from 'apis'
import { Box } from '@chakra-ui/layout'
import { disclousureStore } from '~/store'

type Req = CreateCategory & {
    team_?: SelectsTypes
}

const OptionsTeam: SelectsTypes[] = [
    {
        value: '1',
        label: 'Food Service',
    },
    {
        value: '2',
        label: 'Retail',
    },
]

const CategoryAddPages = () => {
    const setOpenAdd = disclousureStore((v) => v.setOpenAdd)
    const isAdd = disclousureStore((v) => v.isAdd)
    const { create } = categoryService.useCategory()
    const {
        handleSubmit,
        control,
        register,
        formState: { errors },
    } = useForm<Req>({
        defaultValues: {
            team_: OptionsTeam[0],
        },
    })

    const onSubmit: SubmitHandler<Req> = async (data) => {
        await create.mutateAsync({
            ...data,
            team: Number(data.team_?.value),
            target: 0,
            t: 'create',
        })
        setOpenAdd(false)
    }

    return (
        <Modals isOpen={isAdd} setOpen={() => setOpenAdd(false)} size={'4xl'} title="Tambah Kategori">
            <form onSubmit={handleSubmit(onSubmit)}>
                <Box experimental_spaceY={3}>
                    <FormControls
                        label="id"
                        title={'ID'}
                        register={register}
                        errors={errors.id?.message}
                        required={'ID tidak boleh kosong'}
                    />
                    <TextWarning />
                    <FormControls
                        label="name"
                        title={'Nama'}
                        register={register}
                        errors={errors.name?.message}
                        required={'Nama Kategori tidak boleh kosong'}
                    />
                    <FormSelects
                        control={control}
                        label={'team_'}
                        defaultValue={OptionsTeam[0]}
                        options={OptionsTeam}
                        placeholder={'Pilih Tim'}
                        title={'Tim'}
                    />
                </Box>

                <ButtonForm label={'Simpan'} isLoading={create.isLoading} onClose={() => setOpenAdd(false)} />
            </form>
        </Modals>
    )
}

export default CategoryAddPages
