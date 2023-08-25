import { Box } from '@chakra-ui/layout'
import { SubmitHandler, useForm } from 'react-hook-form'
import { ProductTypes, SelectsTypes } from 'apis'
import { Modals, FormSelects, FormControls, ImagePick, ButtonForm, TextWarning, FormControlsTextArea } from 'ui'
import { productService, usePickImage } from 'hooks'
import { SimpleGrid } from '@chakra-ui/react'
import { useSearch } from './function'
import { disclousureStore } from '~/store'

type ProductReq = ProductTypes.CreateProduct & {
    brand_: SelectsTypes
    category_: SelectsTypes
}

const ProductAddPages = () => {
    const { preview, onSelectFile, selectedFile } = usePickImage('product')
    const categorySearch = useSearch('category')
    const brandSearch = useSearch('brand')
    const setOpenAdd = disclousureStore((v) => v.setOpenAdd)
    const isAdd = disclousureStore((v) => v.isAdd)

    const { create } = productService.useProdcut()
    const {
        handleSubmit,
        register,
        getValues,
        control,
        formState: { errors },
    } = useForm<ProductReq>({})

    const onSubmit: SubmitHandler<ProductReq> = async (data) => {
        const brandData = JSON.parse(getValues('brand_.value')) as ProductTypes.Brand
        const catData = JSON.parse(getValues('category_.value')) as ProductTypes.Category

        data.point = Number(data.point)
        data.brand = brandData
        data.category = catData
        data.description = data.description || '-'
        data.image_ = selectedFile
        await create.mutateAsync({ ...data, t: 'create' })
        setOpenAdd(false)
    }

    return (
        <Modals isOpen={isAdd} setOpen={() => setOpenAdd(false)} size={'6xl'} title="Tambah Produk">
            <form onSubmit={handleSubmit(onSubmit)}>
                <SimpleGrid columns={2} columnGap={5} mb={3}>
                    <Box experimental_spaceY={3}>
                        <Box w={'fit-content'} h={'fit-content'}>
                            <ImagePick
                                title="Foto"
                                boxSize={150}
                                idImage="product"
                                imageUrl={preview as string}
                                onChangeInput={(e) => onSelectFile(e.target)}
                            />
                        </Box>
                        <FormControls
                            label="id"
                            title={'ID'}
                            register={register}
                            errors={errors.name?.message}
                            required={'ID tidak boleh kosong'}
                        />
                        <TextWarning />

                        <FormControls
                            label="name"
                            title={'Nama'}
                            register={register}
                            errors={errors.name?.message}
                            required={'Nama tidak boleh kosong'}
                        />

                        <FormControls
                            label="size"
                            title={'Ukuran'}
                            register={register}
                            errors={errors.size?.message}
                            required={'Ukuran tidak boleh kosong'}
                        />
                        <FormControls
                            label="point"
                            title={'Poin'}
                            register={register}
                            errors={errors.point?.message}
                            required={'Poin tidak boleh kosong'}
                            pattern={{
                                value: /^[0-9.]+$/,
                                message: 'Hanya boleh angka dan titik',
                            }}
                        />
                    </Box>

                    <Box experimental_spaceY={3}>
                        <FormSelects
                            async={true}
                            label={'brand_'}
                            control={control}
                            loadOptions={brandSearch}
                            placeholder={'Pilih Brand'}
                            title={'Brand'}
                            errors={errors.brand_?.message}
                            required={'Brand tidak boleh kosong'}
                        />

                        <FormSelects
                            async={true}
                            label={'category_'}
                            control={control}
                            loadOptions={categorySearch}
                            placeholder={'Pilih Kategori'}
                            title={'Kategori'}
                            errors={errors.category_?.message}
                            // required={'Kategori tidak boleh kosong'}
                        />

                        <FormControlsTextArea
                            label="description"
                            title={'Deskripsi'}
                            register={register}
                            errors={errors.description?.message}
                        />
                    </Box>
                </SimpleGrid>
                <ButtonForm label={'Simpan'} isLoading={create.isLoading} onClose={() => setOpenAdd(false)} />
            </form>
        </Modals>
    )
}

export default ProductAddPages
