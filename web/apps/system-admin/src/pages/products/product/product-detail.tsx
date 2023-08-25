import React from 'react'
import { Box, SimpleGrid } from '@chakra-ui/layout'
import { SubmitHandler, useForm } from 'react-hook-form'
import { ProductTypes, SelectsTypes } from 'apis'
import { Modals, FormSelects, FormControls, ImagePick, ButtonForm, FormControlsTextArea, PText, LoadingForm, entity } from 'ui'
import { productService, usePickImage } from 'hooks'
import { useSearch } from './function'
import { disclousureStore } from '~/store'

type ProductReq = ProductTypes.CreateProduct & {
    brand_: SelectsTypes
    category_: SelectsTypes
}

const ProductDetailPage: React.FC<{ id: string }> = ({ id }) => {
    const setIsOpenEdit = disclousureStore((v) => v.setIsOpenEdit)
    const isOpenEdit = disclousureStore((v) => v.isOpenEdit)
    const [loading, setIsLoading] = React.useState(true)
    const { preview, onSelectFile, selectedFile, setPreview } = usePickImage('product')
    const categorySearch = useSearch('category')
    const brandSearch = useSearch('brand')
    const { data, error, isLoading } = productService.useGetProductById(`${id}`)
    const { update } = productService.useProdcut()
    const {
        handleSubmit,
        register,
        getValues,
        control,
        reset,
        setValue,
        formState: { errors },
    } = useForm<ProductReq>({})

    const setDefault = async () => {
        const categoryName = `${data.category.name}`
        const brandName = `${data.brand.name}`
        const cats = `${categoryName} - ${entity.team(String(data.category.team))}`

        await categorySearch(categoryName).then((i) => {
            const find = i.find((v) => v.label === cats) as SelectsTypes
            setValue('category_', find)
        })
        await brandSearch(`${brandName}`).then((i) => {
            const find = i.find((v) => v.label === brandName) as SelectsTypes
            setValue('brand_', find)
        })

        setIsLoading(false)
    }

    React.useEffect(() => {
        if (data) {
            reset(data)
            setDefault()
            setPreview(data.imageUrl)
        }
    }, [data])

    const onSubmit: SubmitHandler<ProductReq> = async (data) => {
        const brandData = JSON.parse(getValues('brand_.value')) as ProductTypes.Brand
        const catData = JSON.parse(getValues('category_.value')) as ProductTypes.Category

        data.point = Number(data.point)
        data.brand = brandData
        data.category = catData
        data.image_ = selectedFile

        await update.mutateAsync({ ...data, t: 'update' })
        setIsOpenEdit(false)
    }

    return (
        <Modals isOpen={isOpenEdit} setOpen={() => setIsOpenEdit(false)} size={'6xl'} title="Detail Produk">
            {error ? (
                <PText label={error} />
            ) : isLoading || loading ? (
                <LoadingForm lenData={8} />
            ) : (
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
                                isDisabled
                                label="id"
                                title={'ID'}
                                register={register}
                                errors={errors.name?.message}
                                required={'ID tidak boleh kosong'}
                            />

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
                                defaultValue={getValues('brand_')}
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
                                defaultValue={getValues('category_')}
                                control={control}
                                loadOptions={categorySearch}
                                placeholder={'Pilih Kategori'}
                                title={'Kategori'}
                                errors={errors.category_?.message}
                                required={'Kategori tidak boleh kosong'}
                            />

                            <FormControlsTextArea
                                label="description"
                                title={'Deskripsi'}
                                register={register}
                                errors={errors.description?.message}
                                required={'Deskripsi tidak boleh kosong'}
                            />
                        </Box>
                    </SimpleGrid>
                    <ButtonForm label={'Simpan'} isLoading={update.isLoading} onClose={() => setIsOpenEdit(false)} />
                </form>
            )}
        </Modals>
    )
}

export default ProductDetailPage
