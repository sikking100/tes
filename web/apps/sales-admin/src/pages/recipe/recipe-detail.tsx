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
import { Recipe } from 'apis'

type RecipeT = Recipe & {
    image_?: File
}

interface RecipeDetailPagesProps {
    data: RecipeT
    isOpen: boolean
    setOpen: (v: boolean) => void
}

const RecipeDetailPages: React.FC<RecipeDetailPagesProps> = ({
    data,
    isOpen,
    setOpen,
}) => {
    const navigate = useNavigate()
    const { preview, onSelectFile, selectedFile, setPreview } = usePickImage()
    const { update } = recipeService.useRecipe()
    const {
        handleSubmit,
        register,
        setValue,
        reset,
        formState: { errors },
    } = useForm<RecipeT>()

    React.useEffect(() => {
        if (isOpen) {
            reset(data)
            setPreview(data.imageUrl)
        }
    }, [isOpen])

    React.useEffect(() => {
        if (selectedFile) {
            setValue('image_', selectedFile)
        }
    }, [selectedFile])

    const onSubmit: SubmitHandler<RecipeT> = async (data) => update.mutate(data)

    return (
        <Modals
            isOpen={true}
            setOpen={() => setOpen(false)}
            size={'4xl'}
            title="Detail Resep"
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
                            title={'Kategory'}
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
                    isLoading={update.isLoading}
                    onClose={() => setOpen(false)}
                />
            </form>
        </Modals>
    )
}

export default RecipeDetailPages
