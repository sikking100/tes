import { Box, HStack } from '@chakra-ui/layout'
import { SubmitHandler, useForm } from 'react-hook-form'
import { Modals, FormControls, ImagePick, ButtonForm, TextWarning } from 'ui'
import { brandService, usePickImage } from 'hooks'
import type { CreateBrand } from 'apis'
import { disclousureStore } from '~/store'

const BrandAddPages: React.FC = () => {
    const { preview, onSelectFile, selectedFile, setSelectedFile, setPreview } = usePickImage('brand')
    const { create } = brandService.useBrand()
    const setOpenAdd = disclousureStore((v) => v.setOpenAdd)
    const isAdd = disclousureStore((v) => v.isAdd)

    const {
        handleSubmit,
        register,
        formState: { errors },
    } = useForm<CreateBrand>()

    const onSubmit: SubmitHandler<CreateBrand> = async (data) => {
        await create.mutateAsync({
            t: 'create',
            name: data.name,
            id: data.id,
            image_: selectedFile,
        })
        // reset()
        setSelectedFile(undefined)
        setPreview('')
        setOpenAdd(false)
    }

    return (
        <Modals isOpen={isAdd} setOpen={() => setOpenAdd(false)} size={'3xl'} title="Tambah Brand">
            <form onSubmit={handleSubmit(onSubmit)}>
                <HStack align={'start'} experimental_spaceX={5}>
                    <Box w={'fit-content'} h={'fit-content'}>
                        <ImagePick
                            title="Foto"
                            boxSize={150}
                            w={200}
                            idImage="npwp"
                            imageUrl={preview as string}
                            onChangeInput={(e) => onSelectFile(e.target)}
                        />
                    </Box>
                    <Box experimental_spaceY={3} w={'full'}>
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
                            title={'Nama Brand'}
                            register={register}
                            errors={errors.name?.message}
                            required={'Nama Brand tidak boleh kosong'}
                        />
                    </Box>
                </HStack>
                <ButtonForm label={'Simpan'} isLoading={create.isLoading} onClose={() => setOpenAdd(false)} />
            </form>
        </Modals>
    )
}

export default BrandAddPages
