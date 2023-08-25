import React from 'react'
import { Root, Tables, PText, Buttons, DeleteConfirm } from 'ui'
import { store, branchService } from 'hooks'
import columns from './warehouse-column'
import { dataListWarehouse } from '../../navigation'
import { AddIcons } from 'ui/src/icons'
import WarehouseDetail from './warehouse-detail'
import WarehouseAddPages from './warehouse-add'
import { disclousureStore } from '../../store'
import { CreateWarehouse } from 'apis'

const Wrap: React.FC<{ children: React.ReactNode }> = ({ children }) => (
    <Root appName="Branch" items={dataListWarehouse} backUrl={'/'} activeNum={1}>
        {children}
    </Root>
)

const WarehousePages = () => {
    const admin = store.useStore((i) => i.admin)
    const { column, id } = columns()
    const { data, error, isLoading } = branchService.useGetBranchId(`${admin?.location.id}`)
    const { createWarehouse } = branchService.useBranch()
    const setOpenAdd = disclousureStore((v) => v.setOpenAdd)
    const isOpenEdit = disclousureStore((v) => v.isOpenEdit)
    const isAdd = disclousureStore((v) => v.isAdd)
    const setIsOpenDeelete = disclousureStore((v) => v.setIsOpenDeelete)
    const isOpenDelete = disclousureStore((v) => v.isOpenDelete)

    const setHeight = React.useMemo(() => {
        if (window.screen.availWidth >= 1920) {
            return '72vh'
        }
        if (window.screen.availWidth >= 1535) {
            return '64vh'
        }
        if (window.screen.availWidth >= 1440) {
            return '60vh'
        }
        if (window.screen.availWidth >= 1366) {
            return '60vh'
        }
        return '100%'
    }, [window.screen.availWidth])

    const onDeleteWarehouse = async () => {
        if (!data || !id) return
        const warehouse = data.warehouse
        const filterWarehouse = warehouse.filter((v) => v.id !== id.id)

        const nMapFilter: CreateWarehouse[] = filterWarehouse.map((v) => {
            const lng = v.address.lngLat[0]
            const lat = v.address.lngLat[1]
            return {
                address: v.address.name,
                addressLat: lat,
                addressLng: lng,
                id: v.id,
                isDefault: v.isDefault,
                name: v.name,
                phone: v.phone,
            }
        })

        await createWarehouse.mutateAsync({ listWarehouse: nMapFilter, idBranch: `${admin?.location?.id}` })
        setIsOpenDeelete(false)
    }

    return (
        <Wrap>
            {isAdd && <WarehouseAddPages />}
            {isOpenEdit && id && <WarehouseDetail data={id} />}
            <DeleteConfirm
                isLoading={createWarehouse.isLoading}
                isOpen={isOpenDelete}
                setOpen={() => setIsOpenDeelete(false)}
                onClose={() => setIsOpenDeelete(false)}
                title="Gudang"
                addsText={true}
                desc={
                    'Data Gudang akan terhapus secara permanen. Sebelum melanjutkan proses ini, pastikan seluruh stok telah ditransfer ke Gudang yang lain.'
                }
                onClick={onDeleteWarehouse}
            />
            <Buttons leftIcon={<AddIcons />} label={'Tambahkan Gudang'} onClick={() => setOpenAdd(true)} mb={3} />

            {error ? (
                <PText label={error} />
            ) : (
                <>
                    <Tables
                        columns={column}
                        isLoading={isLoading}
                        data={isLoading ? [] : data?.warehouse || []}
                        usePaging={true}
                        pageH={setHeight}
                    />
                </>
            )}
        </Wrap>
    )
}

export default WarehousePages
