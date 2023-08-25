import React from 'react'
import { Box, Text, FormControl, FormLabel, Switch } from '@chakra-ui/react'
import { SubmitHandler, useForm } from 'react-hook-form'
import { ButtonForm, FormControls, MapsPickLocation, Modals } from 'ui'
import { RegExPhoneNumber, RegExSpescialChar } from '../../utils/shared'
import type { CreateWarehouse } from 'apis'
import { store, branchService } from 'hooks'
import { toast } from 'react-toastify'
import { disclousureStore } from '../../store'

type ReqTypes = CreateWarehouse

export interface SelectsTypesDefault {
    value: boolean
    label: string
}
export type CreateWare = {
    idBranch: string
    listWarehouse: CreateWarehouse[]
}

const WarehouseAddPages: React.FC = () => {
    const [warehouses, setWarehouses] = React.useState<CreateWarehouse[]>([])
    const admin = store.useStore((i) => i.admin)
    const [isOpenMap, setOpenMap] = React.useState(false)
    const { data, error } = branchService.useGetBranchId(`${admin?.location.id}`)
    const { createWarehouse } = branchService.useBranch()
    const isAdd = disclousureStore((v) => v.isAdd)
    const setOpenAdd = disclousureStore((v) => v.setOpenAdd)

    React.useEffect(() => {
        const dataWarehouse: CreateWarehouse[] = []
        if (!error) {
            if (data?.warehouse.length) {
                data.warehouse.map((v) => {
                    const lng = v.address.lngLat[0]
                    const lat = v.address.lngLat[1]
                    dataWarehouse.push({
                        addressLat: lat,
                        addressLng: lng,
                        address: v.address.name,
                        isDefault: v.isDefault,
                        id: v.id,
                        name: v.name,
                        phone: v.phone,
                    })
                })
            }
            setWarehouses(dataWarehouse)
        }
    }, [!error, data, setWarehouses])

    const {
        handleSubmit,
        register,
        setValue,
        getValues,
        formState: { errors },
    } = useForm<ReqTypes>({ defaultValues: { isDefault: false } })

    const setClose = () => setOpenAdd(false)

    const onSubmit: SubmitHandler<ReqTypes> = async (datareq) => {
        const currentData: CreateWarehouse[] = [...warehouses]
        const ReqData: ReqTypes = {
            id: datareq.id,
            name: datareq.name,
            address: datareq.address,
            addressLat: datareq.addressLat,
            addressLng: datareq.addressLng,
            isDefault: datareq.isDefault,
            phone: datareq.phone,
        }
        currentData.push(ReqData)

        const findTrue = currentData.find((i) => i.isDefault === true)

        if (!findTrue) {
            toast.error('Gudang Utama harus tersedia dalam 1 cabang')
            return
        }

        const DataCreateWarehouse: CreateWare = {
            idBranch: `${data?.id}`,
            listWarehouse: currentData,
        }
        await createWarehouse.mutateAsync(DataCreateWarehouse)
        setClose()
    }
    const setMaps = () => {
        return (
            <MapsPickLocation
                height="40vh"
                currentLoc={(e) => {
                    setValue('address', e.address)
                    setValue('addressLng', e.lng)
                    setValue('addressLat', e.lat)
                }}
            />
        )
    }

    const checkDefaultWarehouse = (e: boolean) => {
        if (e) {
            const findWarehouse = warehouses.findIndex((v) => v.isDefault === true)
            if (findWarehouse !== -1) {
                warehouses[findWarehouse].isDefault = false
            }
            setWarehouses(warehouses)
        }
    }

    return (
        <Modals isOpen={isAdd} setOpen={setClose} size={'4xl'} title="Tambah Gudang">
            {isOpenMap ? <Box mb={1}>{setMaps()}</Box> : null}
            <Text textDecor={'underline'} cursor={'pointer'} textAlign={'right'} fontWeight={500} onClick={() => setOpenMap(!isOpenMap)}>
                {isOpenMap ? 'Hide' : 'Show'} Maps
            </Text>

            <form onSubmit={handleSubmit(onSubmit)}>
                <FormControl display="flex" alignItems="center">
                    <FormLabel htmlFor="warehouse-select" mb="0">
                        Gudang Utama
                    </FormLabel>
                    <Switch
                        id="warehouse-select"
                        onChange={(e) => {
                            checkDefaultWarehouse(e.target.checked)
                            setValue('isDefault', e.target.checked)
                        }}
                        defaultChecked={getValues('isDefault')}
                    />
                </FormControl>
                <Box experimental_spaceY={3}>
                    <FormControls
                        label="id"
                        register={register}
                        title={'ID'}
                        errors={errors.id?.message}
                        required={'ID Gudang tidak boleh kosong'}
                        pattern={{
                            value: RegExSpescialChar,
                            message: 'ID hanya boleh huruf dan angka',
                        }}
                    />
                    <FormControls
                        label="name"
                        register={register}
                        title={'Nama Gudang'}
                        errors={errors.name?.message}
                        required={'Nama Gudang tidak boleh kosong'}
                    />
                    <FormControls
                        label="phone"
                        title={'Nomor HP'}
                        register={register}
                        errors={errors.phone?.message}
                        pattern={{
                            value: RegExPhoneNumber,
                            message: 'Nomor HP tidak valid',
                        }}
                        required={'Nomor HP tidak boleh kosong'}
                    />

                    <FormControls
                        readOnly={false}
                        label="address"
                        register={register}
                        title={'Alamat Gudang'}
                        placeholder={'Pilih Lokasi Gudang'}
                        errors={errors.address?.message}
                        required={'Lokasi Gudang tidak boleh kosong'}
                        onClickInput={() => {
                            setOpenMap(true)
                        }}
                    />

                    <Text fontSize={'sm'} my={2} color={'red.400'} textTransform={'capitalize'}>
                        * Pastikan ID dan Nama Gudang sudah sesuai karena tidak dapat diubah
                    </Text>
                </Box>

                <ButtonForm label={'Simpan'} isLoading={createWarehouse.isLoading} onClose={setClose} />
            </form>
        </Modals>
    )
}

export default WarehouseAddPages
