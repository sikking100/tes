import { ButtonForm, FormSelects, ImagePick, Modals } from 'ui'
import { SelectsTypes, CreateBanner, BannerType } from 'apis'
import { bannerService, usePickImage } from 'hooks'
import { Box } from '@chakra-ui/react'
import { useForm } from 'react-hook-form'
import { disclousureStore } from '~/store'

const TypeBanner: SelectsTypes[] = [
    {
        label: 'Internal',
        value: 'INTERNAL',
    },
    {
        label: 'Publik',
        value: 'EXTERNAL',
    },
]

interface ReqCreateBanner extends CreateBanner {
    type_?: SelectsTypes
}

const BannerAddPages = () => {
    const setOpenadd = disclousureStore((v) => v.setOpenAdd)
    const isAdd = disclousureStore((v) => v.isAdd)
    const { preview, onSelectFile, selectedFile } = usePickImage()
    const {
        handleSubmit,
        control,
        formState: { errors },
    } = useForm<ReqCreateBanner>({
        defaultValues: {
            type_: TypeBanner[0],
        },
    })
    const { create } = bannerService.useBanner()

    const onSubmit = async (req: ReqCreateBanner) => {
        if (!selectedFile) return
        const type = req.type_?.value === 'INTERNAL' ? BannerType.INTERNAL : BannerType.EXTERNAL

        const ReqData: ReqCreateBanner = {
            file: selectedFile,
            type: type,
        }
        await create.mutateAsync(ReqData)
        setOpenadd(false)
    }

    return (
        <Modals isOpen={isAdd} setOpen={() => setOpenadd(false)} size={'3xl'} title="Tambah Banner" scrlBehavior="outside">
            <form onSubmit={handleSubmit(onSubmit)}>
                <Box experimental_spaceY={3}>
                    <Box w={'fit-content'} h={'fit-content'}>
                        <ImagePick
                            title="Foto"
                            w={'full'}
                            h={150}
                            idImage="banner"
                            imageUrl={preview as string}
                            onChangeInput={(e) => onSelectFile(e.target)}
                        />
                    </Box>
                    <FormSelects
                        defaultValue={TypeBanner[0]}
                        options={TypeBanner}
                        label="type_"
                        title={'Tipe'}
                        placeholder="Pilih Tipe Banner"
                        control={control}
                        errors={errors.type_?.value?.message}
                    />
                </Box>

                <ButtonForm label={'Simpan'} isLoading={create.isLoading} onClose={() => setOpenadd(false)} />
            </form>
        </Modals>
    )
}

export default BannerAddPages
