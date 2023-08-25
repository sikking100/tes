import React from 'react'
import { Box, SimpleGrid } from '@chakra-ui/layout'
import { SubmitHandler, useForm } from 'react-hook-form'
import { ButtonForm, FormControls, FormInputWithButton, FormSelects, MapsPickLocation, Modals, TextWarning, Icons } from 'ui'
import { branchService } from 'hooks'
import type { CreateBranch, SelectsTypes, Region } from 'apis'
import { IconButton } from '@chakra-ui/button'
import { disclousureStore } from '~/store'
import { Searchs } from '../users/function'

type Req = CreateBranch & {
    region_: SelectsTypes
}

const BranchAddPages = () => {
    const setOpenAdd = disclousureStore((v) => v.setOpenAdd)
    const isAdd = disclousureStore((v) => v.isAdd)
    const [isOpenMap, setOpenMap] = React.useState(false)
    const bySearchRegion = Searchs('region')
    const { create } = branchService.useBranch()

    const {
        handleSubmit,
        register,
        control,
        setValue,
        formState: { errors },
        getValues,
    } = useForm<Req>()

    const onSubmit: SubmitHandler<Req> = async (data) => {
        const region = JSON.parse(getValues('region_.value')) as Region
        data.regionId = region.id
        data.regionName = region.name
        await create.mutateAsync({ ...data, t: 'create' })
        setOpenAdd(false)
    }

    return (
        <>
            {isAdd && (
                <Modals isOpen={isAdd} setOpen={() => setOpenAdd(false)} size={'6xl'} title="Tambah Cabang" scrlBehavior="outside">
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

                                <FormSelects
                                    async={true}
                                    control={control}
                                    loadOptions={bySearchRegion}
                                    label={'region_'}
                                    placeholder={'Pilih Region'}
                                    required={'Region tidak boleh kosong'}
                                    title={'Region'}
                                />
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
                                            icon={
                                                <Box onClick={() => setOpenMap(true)}>
                                                    <Icons.IconPickMaps color={'black'} />
                                                </Box>
                                            }
                                        />
                                    }
                                />
                            </Box>
                        </SimpleGrid>

                        <ButtonForm label={'Simpan'} isLoading={create.isLoading} onClose={() => setOpenAdd(false)} />
                    </form>
                </Modals>
            )}
        </>
    )
}

export default BranchAddPages
