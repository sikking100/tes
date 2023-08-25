import React from 'react'
import { Box, Text } from '@chakra-ui/layout'
import { SubmitHandler, useForm } from 'react-hook-form'
import { Navigate } from 'react-router-dom'
import { ButtonForm, FormControls, FormControlsTextArea, LoadingForm, Modals, PText } from 'ui'
import { codeService, store } from 'hooks'
import { Code, Eroles } from 'apis'
import { disclousureStore } from '~/store'

const CodeDetailPages: React.FC<{ id: string }> = ({ id }) => {
    const admin = store.useStore((i) => i.admin)
    const { create } = codeService.useCode()
    const { data, error, isLoading } = codeService.useGetCodyById(id)
    const setIsOpenEdit = disclousureStore((v) => v.setIsOpenEdit)
    const isOpenEdit = disclousureStore((v) => v.isOpenEdit)
    const {
        handleSubmit,
        register,
        reset,
        formState: { errors },
    } = useForm<Code>()

    React.useEffect(() => {
        if (data) {
            reset(data)
        }
    }, [isLoading])

    const onSubmit: SubmitHandler<Code> = async (data) => {
        await create.mutateAsync(data)
        setIsOpenEdit(false)
    }

    return (
        <Modals isOpen={isOpenEdit} setOpen={() => setIsOpenEdit(false)} size={'3xl'} title="Detail Kode">
            {!admin ? (
                <Text>Loading...</Text>
            ) : admin.roles === Eroles.SALES_ADMIN ? (
                <>
                    {error ? (
                        <PText label={error} />
                    ) : isLoading ? (
                        <LoadingForm />
                    ) : (
                        <form onSubmit={handleSubmit(onSubmit)}>
                            <Box experimental_spaceY={3}>
                                <FormControls
                                    readOnly
                                    label="id"
                                    register={register}
                                    title={'ID'}
                                    errors={errors.id?.message}
                                    required={'ID tidak boleh kosong'}
                                />
                                <FormControlsTextArea
                                    label="description"
                                    register={register}
                                    title={'Deskripsi'}
                                    errors={errors.description?.message}
                                    required={'Deskripsi tidak boleh kosong'}
                                />
                            </Box>
                            <ButtonForm label={'Simpan'} isLoading={create.isLoading} onClose={() => setIsOpenEdit(false)} />
                        </form>
                    )}
                </>
            ) : (
                <Navigate to={'/'} />
            )}
        </Modals>
    )
}

export default CodeDetailPages
