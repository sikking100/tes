import React from 'react'
import { Box } from '@chakra-ui/layout'
import { SubmitHandler, useForm } from 'react-hook-form'
import { Modals, FormControls, ButtonForm, entity, FormControlNumbers } from 'ui'
import { Eroles, type Category, type SelectsTypes } from 'apis'
import { categoryService, store } from 'hooks'
import { disclousureStore } from '~/store'

type Req = Category & {
    team_?: SelectsTypes
}

const CategoryDetailPages: React.FC<{
    data: Category
}> = ({ data }) => {
    const { create } = categoryService.useCategory()
    const admin = store.useStore((v) => v.admin)
    const setIsOpenEdit = disclousureStore((v) => v.setIsOpenEdit)
    const isOpenEdit = disclousureStore((v) => v.isOpenEdit)

    const {
        handleSubmit,
        register,
        control,
        reset,
        formState: { errors },
    } = useForm<Req>()

    React.useEffect(() => {
        if (data)
            reset({
                ...data,
                team_: {
                    value: `${entity.team(String(data.team))}`,
                    label: `${entity.team(String(data.team))}`,
                },
            })
    }, [data])

    const onClose = () => setIsOpenEdit(false)

    const onSubmit: SubmitHandler<Req> = async (data) => {
        data.target = Number(data.target)
        await create.mutateAsync({ ...data, t: 'update' })
        onClose()
    }

    return (
        <Modals isOpen={isOpenEdit} setOpen={onClose} size={'4xl'} title="Detail Kategori">
            <React.Fragment>
                <form onSubmit={handleSubmit(onSubmit)}>
                    <Box experimental_spaceY={3}>
                        <FormControls
                            readOnly
                            label="id"
                            title={'ID'}
                            register={register}
                            errors={errors.id?.message}
                            required={'ID tidak boleh kosong'}
                        />
                        <FormControls
                            readOnly
                            label="name"
                            title={'Nama'}
                            register={register}
                            errors={errors.name?.message}
                            required={'Nama Kategori tidak boleh kosong'}
                        />

                        {admin?.roles === Eroles.SALES_ADMIN && (
                            <FormControlNumbers title="Target" label={'target'} register={register} control={control} />
                        )}

                        {admin?.roles === Eroles.BRANCH_SALES_ADMIN && (
                            <FormControls readOnly label="target" title={'Target'} register={register} />
                        )}

                        <FormControls
                            readOnly
                            label="team_.value"
                            title={'Tim'}
                            register={register}
                            errors={errors.name?.message}
                            required={'Target tidak boleh kosong'}
                        />
                    </Box>
                    <ButtonForm label={'Simpan'} isLoading={create.isLoading} onClose={onClose} />
                </form>
            </React.Fragment>
        </Modals>
    )
}

export default CategoryDetailPages
