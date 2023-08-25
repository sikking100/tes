import React from 'react'
import { Box, Text } from '@chakra-ui/layout'
import { SubmitHandler, useForm } from 'react-hook-form'
import { ButtonForm, FormControls, MapsPickLocation, Modals } from 'ui'
import { RegExSpescialChar } from '../../utils/shared'
import { RegExPhoneNumber } from 'ui/src/utils/shared'
import { FormControl, FormLabel, Switch } from '@chakra-ui/react'
import { branchService, store } from 'hooks'
import { CreateWarehouse, Warehouse } from 'apis'
import { CreateWare } from './warehouse-add'
import { toast } from 'react-toastify'
import { disclousureStore } from '../../store'

const WarehouseDetail: React.FC<{
    data: Warehouse
}> = ({ data }) => {
    const admin = store.useStore((i) => i.admin)
    const [isOpenMap, setOpenMap] = React.useState(false)
    const [warehouse, setWarehouses] = React.useState<Warehouse[]>([])
    const {
        handleSubmit,
        register,
        setValue,
        reset,
        getValues,
        formState: { errors },
    } = useForm<CreateWarehouse>()
    const { data: dataBranch, isLoading } = branchService.useGetBranchId(`${admin?.location.id}`)
    const { createWarehouse } = branchService.useBranch()
    const isOpenEdit = disclousureStore((v) => v.isOpenEdit)
    const setIsOpenEdit = disclousureStore((v) => v.setIsOpenEdit)

    React.useEffect(() => {
        if (dataBranch) {
            setWarehouses(dataBranch.warehouse)
        }
    }, [isLoading])

    React.useEffect(() => {
        reset({
            id: data.id,
            address: data.address.name,
            addressLat: data.address.lngLat[1],
            addressLng: data.address.lngLat[0],
            isDefault: data.isDefault,
            name: data.name,
            phone: data.phone,
        })
    }, [data])

    const setClose = () => setIsOpenEdit(false)

    const onSubmit: SubmitHandler<CreateWarehouse> = async (datareq) => {
        if (!dataBranch) return
        const ReqData: CreateWarehouse = {
            id: datareq.id,
            name: datareq.name,
            address: datareq.address,
            addressLat: datareq.addressLat,
            addressLng: datareq.addressLng,
            isDefault: datareq.isDefault,
            phone: datareq.phone,
        }
        const transformData: CreateWarehouse[] = dataBranch.warehouse.map((i) => {
            if (i.id !== datareq.id) {
                return {
                    id: i.id,
                    address: i.address.name,
                    addressLat: i.address.lngLat[1],
                    addressLng: i.address.lngLat[0],
                    isDefault: i.isDefault,
                    name: i.name,
                    phone: i.phone,
                }
            }
            return {
                ...ReqData,
            }
        })

        const findTrue = transformData.find((i) => i.isDefault === true)

        if (!findTrue) {
            toast.error('Gudang Utama harus tersedia dalam 1 cabang')
            return
        }

        const DataCreateWarehouse: CreateWare = {
            idBranch: data.id,
            listWarehouse: transformData,
        }
        await createWarehouse.mutateAsync(DataCreateWarehouse)
        // reset()
        setClose()
    }

    const checkDefaultWarehouse = (e: boolean) => {
        if (e) {
            const findWarehouse = warehouse.findIndex((v) => v.isDefault === true)
            if (findWarehouse !== -1) {
                warehouse[findWarehouse].isDefault = false
            }
            setWarehouses(warehouse)
        }
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

    return (
        <Modals isOpen={isOpenEdit} setOpen={setClose} size={'4xl'} title="Detail Gudang">
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
                        readOnly={true}
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
                        readOnly={true}
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
                </Box>

                <ButtonForm label={'Simpan'} isLoading={createWarehouse.isLoading} onClose={setClose} />
            </form>
        </Modals>
    )
}

export default WarehouseDetail
