import React from 'react'
import { Box } from '@chakra-ui/layout'
import { SubmitHandler, useForm } from 'react-hook-form'
import { Modals, FormControls, ButtonForm, PText, LoadingForm, FormSelects } from 'ui'
import type { Category, SelectsTypes } from 'apis'
import { categoryService } from 'hooks'
import { disclousureStore } from '~/store'

type Req = Category & {
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

const CategoryDetailPages: React.FC<{ id: string }> = ({ id }) => {
    const setIsOpenEdit = disclousureStore((v) => v.setIsOpenEdit)
    const isOpenEdit = disclousureStore((v) => v.isOpenEdit)
    const { create } = categoryService.useCategory()
    const { data, isLoading, error } = categoryService.useGetCategoryById(String(id))
    const {
        handleSubmit,
        control,
        register,
        reset,
        setValue,
        formState: { errors },
    } = useForm<Req>()

    React.useEffect(() => {
        if (data) {
            reset(data)
            setValue('team_', OptionsTeam[data.team - 1])
        }
    }, [data])

    const onSubmit: SubmitHandler<Req> = async (data) => {
        data.team = Number(data.team_?.value)
        await create.mutateAsync({ ...data, t: 'update' })
        setIsOpenEdit(false)
    }

    return (
        <Modals isOpen={isOpenEdit} setOpen={() => setIsOpenEdit(false)} size={'4xl'} title="Detail Kategori">
            {error ? (
                <PText label={error} />
            ) : isLoading ? (
                <LoadingForm />
            ) : (
                <React.Fragment>
                    <form onSubmit={handleSubmit(onSubmit)}>
                        <Box experimental_spaceY={3}>
                            <FormControls
                                isDisabled
                                label="id"
                                title={'ID'}
                                register={register}
                                errors={errors.id?.message}
                                required={'ID tidak boleh kosong'}
                            />
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
                        <ButtonForm label={'Simpan'} isLoading={create.isLoading} onClose={() => setIsOpenEdit(false)} />
                    </form>
                </React.Fragment>
            )}
        </Modals>
    )
}

export default CategoryDetailPages
