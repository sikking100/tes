import React from 'react'
import { useForm } from 'react-hook-form'
import { Modals, FormControls, FormControlsTextArea } from 'ui'
import { usePickImage } from 'hooks'
import { Image, Box, SimpleGrid, VisuallyHidden } from '@chakra-ui/react'
import { Brand, Category, ProductTypes, SelectsTypes } from 'apis'
import { searchs } from './function'
import { disclousureStore } from '~/store'

type ProductReq = ProductTypes.Product & {
    image_?: File
    brand_?: SelectsTypes
    category_?: SelectsTypes
}
interface Props {
    data: ProductTypes.Product
}

const ProductDetailPages: React.FC<Props> = ({ data }) => {
    const setEditOpen = disclousureStore((v) => v.setIsOpenEdit)
    const isOpenEdit = disclousureStore((v) => v.isOpenEdit)
    const categorySearch = searchs('category')
    const brandSearch = searchs('brand')
    const { preview, setPreview } = usePickImage()

    const {
        register,
        reset,
        getValues,
        setValue,
        formState: { errors },
    } = useForm<ProductReq>()

    const setDefault = async () => {
        const categoryName = `${data.category.name}`
        const brandName = `${data.brand.name}`

        await categorySearch(`${categoryName}`).then((i) => {
            const find = i.find((v) => {
                const d = JSON.parse(v.value) as Category
                if (d.id === data.category.id) return true
            }) as SelectsTypes
            setValue('category_', find)
        })
        await brandSearch(`${brandName}`).then((i) => {
            const find = i.find((v) => {
                const d = JSON.parse(v.value) as Brand
                if (d.id === data.brand.id) return true
            }) as SelectsTypes
            setValue('brand_', find)
        })
    }

    React.useEffect(() => {
        reset({
            ...data,
        })
        setDefault()
        setPreview(data.imageUrl)
    }, [])

    const onClose = () => setEditOpen(false)

    return (
        <Modals isOpen={isOpenEdit} setOpen={onClose} size={'5xl'} title="Detail Produk">
            <>
                <VisuallyHidden>{JSON.stringify(getValues('brand_'))}</VisuallyHidden>
                <VisuallyHidden>{JSON.stringify(getValues('category_'))}</VisuallyHidden>
                <SimpleGrid columns={2} columnGap={5} mb={3}>
                    <Box experimental_spaceY={3}>
                        <Box w={'fit-content'} h={'fit-content'} shadow={'md'} p={2} rounded={'md'}>
                            <Image title="Foto" boxSize={150} src={preview as string} objectFit={'contain'} />
                        </Box>
                        <FormControls
                            readOnly
                            label="id"
                            title={'ID'}
                            register={register}
                            errors={errors.name?.message}
                            required={'ID tidak boleh kosong'}
                        />
                        <FormControls
                            readOnly
                            label="name"
                            title={'Nama'}
                            register={register}
                            errors={errors.name?.message}
                            required={'Nama tidak boleh kosong'}
                        />
                        <FormControls
                            readOnly
                            label="size"
                            title={'Ukuran'}
                            register={register}
                            errors={errors.size?.message}
                            required={'Ukuran tidak boleh kosong'}
                        />
                        <FormControls
                            readOnly
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
                        <FormControls
                            readOnly
                            label="brand.name"
                            title={'Brand'}
                            register={register}
                            errors={errors.point?.message}
                            required={'Brand tidak boleh kosong'}
                            pattern={{
                                value: /^[0-9.]+$/,
                                message: 'Hanya boleh angka dan titik',
                            }}
                        />
                        <FormControls
                            readOnly
                            label="category.name"
                            title={'Kategori'}
                            register={register}
                            errors={errors.point?.message}
                            required={'Brand tidak boleh kosong'}
                            pattern={{
                                value: /^[0-9.]+$/,
                                message: 'Hanya boleh angka dan titik',
                            }}
                        />

                        <FormControlsTextArea
                            readOnly
                            label="description"
                            title={'Deskripsi'}
                            register={register}
                            errors={errors.description?.message}
                            required={'Deskripsi tidak boleh kosong'}
                        />
                    </Box>
                </SimpleGrid>
            </>
        </Modals>
    )
}

export default ProductDetailPages
