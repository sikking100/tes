import React from 'react'
import { Box, SimpleGrid } from '@chakra-ui/layout'
import { SubmitHandler, useForm } from 'react-hook-form'
import { ButtonForm, FormControls, ImagePick, Modals, FormControlsTextArea } from 'ui'
import { activityService, store, usePickImage } from 'hooks'
import type { CreateActivity } from 'apis'
import RadioButtonTypes from './radio-button-type'
import { disclousureStore } from '~/store'

const ActivityAddPages = () => {
    const user = store.useStore((i) => i.admin)
    const [typeActivity, setTypeActivity] = React.useState('1')
    const { preview, onSelectFile, selectedFile } = usePickImage('product')
    const { create } = activityService.useActivity()
    const isAdd = disclousureStore((v) => v.isAdd)
    const setOpenAdd = disclousureStore((v) => v.setOpenAdd)

    const {
        handleSubmit,
        register,
        formState: { errors },
        setValue,
    } = useForm<CreateActivity>()

    React.useEffect(() => {
        if (selectedFile) setValue('image_', selectedFile)
    }, [selectedFile])

    React.useEffect(() => {
        if (user) {
            setValue('creator', {
                id: user.id,
                description: '-',
                imageUrl: user.imageUrl,
                name: user.name,
                roles: user.roles,
            })
        }
    }, [user])

    const onSubmit: SubmitHandler<CreateActivity> = async (data) => {
        await create.mutateAsync(data)
        setOpenAdd(false)
    }

    return (
        <Modals isOpen={isAdd} setOpen={() => setOpenAdd(false)} size={'3xl'} title="Tambah Aktivitas">
            <form onSubmit={handleSubmit(onSubmit)}>
                <SimpleGrid columns={2} gap={5}>
                    <Box experimental_spaceY={3}>
                        <RadioButtonTypes setType={setTypeActivity} defaultType={typeActivity} />
                        {typeActivity === '1' ? (
                            <Box w={'fit-content'} h={'fit-content'}>
                                <ImagePick
                                    title="Foto"
                                    boxSize={150}
                                    idImage="npwp"
                                    imageUrl={preview as string}
                                    onChangeInput={(e) => onSelectFile(e.target)}
                                />
                            </Box>
                        ) : typeActivity === '2' ? (
                            <FormControls label="videoUrl" register={register} title={'URL Video'} errors={errors.videoUrl?.message} />
                        ) : null}
                        <FormControls
                            label="title"
                            register={register}
                            title={'Judul '}
                            errors={errors.title?.message}
                            required={'Judul tidak boleh kosong'}
                        />
                    </Box>
                    <Box experimental_spaceY={3}>
                        <FormControlsTextArea
                            label="description"
                            register={register}
                            title={'Deskripsi'}
                            errors={errors.description?.message}
                            required={'Deskripsi tidak boleh kosong'}
                        />
                    </Box>
                </SimpleGrid>
                <ButtonForm label={'Simpan'} isLoading={create.isLoading} onClose={() => setOpenAdd(false)} />
            </form>
        </Modals>
    )
}

export default ActivityAddPages
