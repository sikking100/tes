import React from 'react'
import { Box } from '@chakra-ui/layout'
import { useNavigate, useParams } from 'react-router-dom'
import { SubmitHandler, useForm } from 'react-hook-form'
import { ProductTypes, SelectsTypes } from 'apis'
import { Modals, FormSelects, FormControls, FormControlsTextArea, PText, LoadingForm } from 'ui'
import { productService, usePickImage } from 'hooks'
import { Image, SimpleGrid } from '@chakra-ui/react'

type ProductReq = ProductTypes.CreateProduct & {
  brand_: SelectsTypes
  category_: SelectsTypes
}

const ProductDetailPage: React.FC<{
  id: string
  isOpen: boolean
  setOpen: (v: boolean) => void
}> = ({ id, isOpen, setOpen }) => {
  const [loading, setIsLoading] = React.useState(true)
  const { preview, onSelectFile, selectedFile, setPreview } = usePickImage('product')
  const { data, error, isLoading } = productService.useGetProductById(`${id}`)
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
    setIsLoading(false)
  }

  const setClose = () => setOpen(false)

  React.useEffect(() => {
    if (data) {
      reset(data)
      setDefault()
      setPreview(data.imageUrl)
    }
  }, [data])

  return (
    <Modals isOpen={isOpen} setOpen={setClose} size={'6xl'} title='Detail Produk'>
      {error ? (
        <PText label={error} />
      ) : isLoading || loading ? (
        <LoadingForm lenData={8} />
      ) : (
        <>
          <SimpleGrid columns={2} columnGap={5} mb={3}>
            <Box experimental_spaceY={3}>
              <Box w={'fit-content'} h={'fit-content'}>
                <Image boxSize={150} src={preview as string} />
              </Box>
              <FormControls
                isDisabled={true}
                label='id'
                title={'ID'}
                register={register}
                errors={errors.name?.message}
                required={'ID tidak boleh kosong'}
              />

              <FormControls
                isDisabled={true}
                label='name'
                title={'Nama'}
                register={register}
                errors={errors.name?.message}
                required={'Nama tidak boleh kosong'}
              />

              <FormControls
                isDisabled={true}
                label='size'
                title={'Ukuran'}
                register={register}
                errors={errors.size?.message}
                required={'Ukuran tidak boleh kosong'}
              />
              <FormControls
                isDisabled={true}
                label='point'
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
                defaultValue={{
                  value: getValues('brand.name'),
                  label: getValues('brand.name'),
                }}
                label={'brand'}
                control={control}
                title={'Brand'}
                isDisabled={true}
              />

              <FormSelects
                async={true}
                label={'category'}
                defaultValue={{
                  value: getValues('category.name'),
                  label: getValues('category.name'),
                }}
                control={control}
                title={'Kategori'}
                isDisabled={true}
              />

              <FormControlsTextArea
                label='description'
                title={'Deskripsi'}
                register={register}
                errors={errors.description?.message}
                required={'Deskripsi tidak boleh kosong'}
              />
            </Box>
          </SimpleGrid>
        </>
      )}
    </Modals>
  )
}

export default ProductDetailPage
