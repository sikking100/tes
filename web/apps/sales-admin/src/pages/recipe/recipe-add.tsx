import React from 'react'
import { Box, SimpleGrid } from '@chakra-ui/layout'
import { SubmitHandler, useForm } from 'react-hook-form'
import { useNavigate } from 'react-router-dom'
import {
    ButtonForm,
    FormControls,
    FormControlsTextArea,
    ImagePick,
    Modals,
} from 'ui'
import { recipeService, usePickImage } from 'hooks'
import { CreateRecipe } from 'apis'

type ReqTypes = CreateRecipe & {
    image_?: File
}

const RecipeAddPages: React.FC<{
    isOpen: boolean
    setOpen: (v: boolean) => void
}> = ({ isOpen, setOpen }) => {
    const navigate = useNavigate()
    const { preview, onSelectFile, selectedFile, setPreview } = usePickImage()
    const { create } = recipeService.useRecipe()

    const {
        handleSubmit,
        register,
        control,
        setValue,
        reset,
        formState: { errors },
    } = useForm<ReqTypes>()

    React.useEffect(() => {
        if (selectedFile) {
            setValue('image_', selectedFile)
        }
    }, [selectedFile])

    const onSubmit: SubmitHandler<ReqTypes> = async (data) =>
        create.mutate(data)

    return (
        <Modals
            isOpen={isOpen}
            setOpen={() => setOpen(false)}
            size={'4xl'}
            title="Tambah Resep"
        >
            <form onSubmit={handleSubmit(onSubmit)}>
                <SimpleGrid columns={2} columnGap={5} mb={3}>
                    <Box experimental_spaceY={3}>
                        <Box w={'fit-content'} h={'fit-content'}>
                            <ImagePick
                                title="Foto"
                                boxSize={150}
                                idImage="recipe"
                                imageUrl={preview as string}
                                onChangeInput={(e) => onSelectFile(e.target)}
                            />
                        </Box>
                        <FormControls
                            label="title"
                            title={'Judul'}
                            register={register}
                            errors={errors.title?.message}
                            required={'Judul tidak boleh kosong'}
                        />
                    </Box>
                    <Box experimental_spaceY={3}>
                        <FormControls
                            label="category"
                            register={register}
                            title={'Kategori'}
                            errors={errors.category?.message}
                            required={'Kategori tidak boleh kosong'}
                        />
                        <FormControlsTextArea
                            label="description"
                            register={register}
                            title={'Deskripsi'}
                            errors={errors.description?.message}
                            required={'Deskripsi tidak boleh kosong'}
                        />
                    </Box>
                </SimpleGrid>

                <ButtonForm
                    label={'Simpan'}
                    isLoading={create.isLoading}
                    onClose={() => setOpen(false)}
                />
            </form>
        </Modals>
    )
}

export default RecipeAddPages
