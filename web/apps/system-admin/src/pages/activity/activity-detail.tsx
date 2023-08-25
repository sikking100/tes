import React from 'react'
import { Box, SimpleGrid } from '@chakra-ui/layout'
import { SubmitHandler, useForm } from 'react-hook-form'
import { ButtonForm, FormControls, FormControlsTextArea, ImagePick, LoadingForm, Modals, PText } from 'ui'
import { activityService, store, usePickImage } from 'hooks'
import type { UpdateActivity } from 'apis'

import RadioButtonTypes from './radio-button-type'
import { disclousureStore } from '~/store'

const ActivityDetailPages: React.FC<{ id: string }> = ({ id }) => {
    const user = store.useStore((i) => i.admin)
    const { preview, onSelectFile, selectedFile, setPreview } = usePickImage('product')
    const [typeActivity, setTypeActivity] = React.useState('1')
    const { update } = activityService.useActivity()
    const { data, isLoading, error } = activityService.useGetActivityById(id)
    const setIsOpenEdit = disclousureStore((v) => v.setIsOpenEdit)
    const isOpenEdit = disclousureStore((v) => v.isOpenEdit)

    const {
        handleSubmit,
        register,
        formState: { errors },
        reset,
        setValue,
    } = useForm<UpdateActivity>()

    React.useEffect(() => {
        if (data) {
            if (data.videoUrl === '-') setTypeActivity('1')
            else setTypeActivity('2')
            reset(data)
            setPreview(data.imageUrl)
        }
    }, [data])

    React.useEffect(() => {
        if (user) {
            setValue('creator.id', user.id)
            setValue('creator.name', user.name)
            setValue('creator.roles', user.roles)
        }
    }, [user])

    React.useEffect(() => {
        if (selectedFile) setValue('image_', selectedFile)
    }, [selectedFile])

    const onSubmit: SubmitHandler<UpdateActivity> = async (data) => {
        await update.mutateAsync(data)
        setIsOpenEdit(false)
    }

    return (
        <Modals isOpen={isOpenEdit} setOpen={() => setIsOpenEdit(false)} size={'3xl'} title="Detail Aktivitas">
            {error ? (
                <PText label={error} />
            ) : isLoading ? (
                <LoadingForm />
            ) : (
                <React.Fragment>
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
                                    <FormControls
                                        label="videoUrl"
                                        register={register}
                                        title={'URL Video'}
                                        errors={errors.videoUrl?.message}
                                        required={'Video URL tidak boleh kosong'}
                                    />
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
                        <ButtonForm label={'Simpan'} isLoading={update.isLoading} onClose={() => setIsOpenEdit(false)} />
                    </form>
                </React.Fragment>
            )}
        </Modals>
    )
}

export default ActivityDetailPages
