import React from 'react'
import { Box, HStack } from '@chakra-ui/layout'
import { SubmitHandler, useForm } from 'react-hook-form'
import { Modals, FormControls, ImagePick, ButtonForm, PText, LoadingForm } from 'ui'
import { brandService, usePickImage } from 'hooks'
import type { CreateBrand } from 'apis'
import { disclousureStore } from '~/store'

const BrandDetailPages: React.FC<{
    id: string
}> = ({ id }) => {
    const { preview, onSelectFile, selectedFile, setPreview } = usePickImage('brand')
    const { create } = brandService.useBrand()
    const { data, error, isLoading } = brandService.useGetBranById(id)
    const setIsOpenEdit = disclousureStore((v) => v.setIsOpenEdit)
    const isOpenEdit = disclousureStore((v) => v.isOpenEdit)
    const {
        handleSubmit,
        register,
        reset,
        formState: { errors },
    } = useForm<CreateBrand>()

    const setClose = () => setIsOpenEdit(false)

    React.useEffect(() => {
        if (data) {
            reset(data)
            setPreview(data.imageUrl)
        }
    }, [data])

    const onSubmit: SubmitHandler<CreateBrand> = async (data) => {
        await create.mutateAsync({
            t: 'update',
            name: data.name,
            id: data.id,
            image_: selectedFile,
        })
        reset()
    }

    return (
        <Modals isOpen={isOpenEdit} setOpen={setClose} size={'3xl'} title="Edit Brand">
            {error ? (
                <PText label={error} />
            ) : isLoading ? (
                <LoadingForm />
            ) : (
                <form onSubmit={handleSubmit(onSubmit)}>
                    <HStack align={'start'} experimental_spaceX={5}>
                        <Box w={'fit-content'} h={'fit-content'}>
                            <ImagePick
                                title="Foto"
                                boxSize={150}
                                w={200}
                                idImage="brand"
                                imageUrl={preview as string}
                                onChangeInput={(e) => onSelectFile(e.target)}
                            />
                        </Box>
                        <Box experimental_spaceY={3} w={'full'}>
                            <FormControls
                                label="id"
                                isDisabled
                                title={'ID'}
                                register={register}
                                errors={errors.id?.message}
                                required={'ID tidak boleh kosong'}
                            />

                            <FormControls
                                label="name"
                                title={'Nama Brand'}
                                register={register}
                                errors={errors.name?.message}
                                required={'Nama Brand tidak boleh kosong'}
                            />
                        </Box>
                    </HStack>
                    <ButtonForm label={'Simpan'} isLoading={create.isLoading} onClose={setClose} />
                </form>
            )}
        </Modals>
    )
}

export default BrandDetailPages
