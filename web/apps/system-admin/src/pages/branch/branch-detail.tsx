import React from 'react'
import { Box, SimpleGrid } from '@chakra-ui/layout'
import { SubmitHandler, useForm } from 'react-hook-form'
import { ButtonForm, FormControls, FormInputWithButton, FormSelects, LoadingForm, MapsPickLocation, Modals, PText, TextWarning } from 'ui'
import { branchService } from 'hooks'
import type { CreateBranch, SelectsTypes, Region } from 'apis'
import { IconButton } from '@chakra-ui/button'
import { GoLocation } from 'react-icons/go'
import { disclousureStore } from '~/store'
import { Searchs } from '../users/function'
import { Skeleton } from '@chakra-ui/react'

type Req = CreateBranch & {
    region_: SelectsTypes
}

const BranchDetailPages: React.FC<{ id: string }> = ({ id }) => {
    const isOpen = disclousureStore((v) => v.isOpenEdit)
    const setIsOpenEdit = disclousureStore((v) => v.setIsOpenEdit)
    const [isOpenMap, setOpenMap] = React.useState(false)
    const bySearchRegion = Searchs('region')
    const { create } = branchService.useBranch()
    const [isLoadingRegion, setLoadingRegion] = React.useState(true)
    const { data, error, isLoading } = branchService.useGetBranchId(id)

    const {
        handleSubmit,
        register,
        control,
        setValue,
        formState: { errors },
        reset,
        getValues,
    } = useForm<Req>()

    const setDefault = async () => {
        const regionName = `${data?.region.name}`
        const region = await bySearchRegion(regionName)
        const dFilter = region.filter((v) => {
            const parse = JSON.parse(v.value) as Region
            return parse.id === data?.region.id
        })
        setValue('region_', dFilter[0])
        setLoadingRegion(false)
    }

    React.useEffect(() => {
        if (data) {
            setDefault()
            reset({
                id: data.id,
                address: data.address.name,
                addressLat: 0,
                addressLng: 0,
                name: data.name,
                regionId: data.region.id,
                regionName: data.region.name,
            })
        }
    }, [data])

    const onSubmit: SubmitHandler<Req> = async (data) => {
        const region = JSON.parse(getValues('region_.value')) as Region
        data.regionId = region.id
        data.regionName = region.name
        await create.mutateAsync({ ...data, t: 'create' })
        setIsOpenEdit(false)
    }

    return (
        <Modals isOpen={isOpen} setOpen={() => setIsOpenEdit(false)} size={'6xl'} title="Tambah Cabang" scrlBehavior="outside">
            {isOpenMap ? (
                <Box>
                    <MapsPickLocation
                        height="40vh"
                        currentLoc={(e) => {
                            setValue('address', e.address)
                            setValue('addressLat', e.lat)
                            setValue('addressLng', e.lng)
                        }}
                    />
                </Box>
            ) : null}
            {error ? (
                <PText label={error} />
            ) : isLoading ? (
                <LoadingForm />
            ) : (
                <form onSubmit={handleSubmit(onSubmit)}>
                    <SimpleGrid columns={2} gap={5} mt={2}>
                        <Box experimental_spaceY={3}>
                            <FormControls
                                label="id"
                                register={register}
                                title={'ID'}
                                errors={errors.id?.message}
                                required={'ID tidak boleh kosong'}
                            />
                            <TextWarning />

                            {isLoadingRegion && <Skeleton w={'full'} h={'25px'} />}

                            {!isLoadingRegion && (
                                <FormSelects
                                    async={true}
                                    control={control}
                                    defaultValue={getValues('region_')}
                                    loadOptions={bySearchRegion}
                                    label={'region_'}
                                    placeholder={'Pilih Region'}
                                    required={'Region tidak boleh kosong'}
                                    title={'Region'}
                                />
                            )}
                        </Box>

                        <Box experimental_spaceY={3}>
                            <FormControls
                                label="name"
                                register={register}
                                title={'Nama'}
                                errors={errors.name?.message}
                                required={'Nama tidak boleh kosong'}
                            />
                            <FormInputWithButton
                                label="address"
                                title={'Alamat'}
                                register={register}
                                errors={errors.address?.message}
                                required={'Alamat tidak boleh kosong'}
                                rChild={
                                    <IconButton
                                        h="1.75rem"
                                        aria-label="icon maps"
                                        icon={<GoLocation color={'red'} onClick={() => setOpenMap(true)} />}
                                    />
                                }
                            />
                        </Box>
                    </SimpleGrid>

                    <ButtonForm label={'Simpan'} isLoading={create.isLoading} onClose={() => setIsOpenEdit(false)} />
                </form>
            )}
        </Modals>
    )
}

export default BranchDetailPages
