import React from 'react'
import { Box, Text } from '@chakra-ui/layout'
import { SubmitHandler, useForm } from 'react-hook-form'
import { Navigate } from 'react-router-dom'
import { ButtonForm, FormControls, FormControlsTextArea, Modals, TextWarning } from 'ui'
import { codeService, store } from 'hooks'
import { Code } from 'apis'
import { disclousureStore } from '~/store'

const CodeAddPages = () => {
    const admin = store.useStore((i) => i.admin)
    const setOpenAdd = disclousureStore((v) => v.setOpenAdd)
    const isAdd = disclousureStore((v) => v.isAdd)
    const { create } = codeService.useCode()

    const {
        handleSubmit,
        register,
        formState: { errors },
    } = useForm<Code>()

    const onSubmit: SubmitHandler<Code> = async (data) => {
        await create.mutateAsync(data)
        setOpenAdd(false)
    }

    return (
        <Modals isOpen={isAdd} setOpen={() => setOpenAdd(false)} size={'3xl'} title="Tambah Kode">
            {!admin ? (
                <Text>Loading...</Text>
            ) : admin.roles === 3 ? (
                <>
                    <form onSubmit={handleSubmit(onSubmit)}>
                        <Box experimental_spaceY={3}>
                            <FormControls
                                label="id"
                                register={register}
                                title={'ID'}
                                errors={errors.id?.message}
                                required={'ID tidak boleh kosong'}
                            />
                            <TextWarning />
                            <FormControlsTextArea
                                label="description"
                                register={register}
                                title={'Deskripsi'}
                                errors={errors.description?.message}
                                required={'Deskripsi tidak boleh kosong'}
                            />
                        </Box>
                        <ButtonForm label={'Simpan'} isLoading={create.isLoading} onClose={() => setOpenAdd(false)} />
                    </form>
                </>
            ) : (
                <Navigate to={'/'} />
            )}
        </Modals>
    )
}

export default CodeAddPages
