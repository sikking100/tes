import React, { FC, ReactNode } from 'react'
import { Tables, SearchInput, Root, DeleteConfirm, PagingButton, PText } from 'ui'
import columnsCourier from './courier-columns'
import { dataListCourier } from '~/navigation'
import { employeeService, setHeight, store } from 'hooks'
import CourierAddPages from './courier-add'
import CourierDetailPages from './courier-details'
import { disclousureStore } from '~/store'
import { Eroles } from 'apis'
import DetailDelivery from './detail-delivery'

const Wrap: FC<{ children: ReactNode }> = ({ children }) => (
    <Root appName="Warehouse" items={dataListCourier} backUrl={'/'} activeNum={1}>
        {children}
    </Root>
)

const CourierPages = () => {
    const admin = store.useStore((i) => i.admin)
    const height = setHeight({ useSearch: true })
    const { data, page, setPage, setQ, error, isLoading } = employeeService.useGetEmployee({
        query: `${Eroles.COURIER},${admin?.location.id}`,
    })
    const { column, id, isDetailDelivery, setDetailDelivery } = columnsCourier()
    const { remove } = employeeService.useEmployee()
    const setOpenAdd = disclousureStore((v) => v.setOpenAdd)
    const isAdd = disclousureStore((v) => v.isAdd)
    const isOpenEdit = disclousureStore((v) => v.isOpenEdit)
    const setIsOpenDelete = disclousureStore((v) => v.setIsOpenDelete)
    const isOpenDelete = disclousureStore((v) => v.isOpenDelete)

    const handleDelete = async (id: string) => {
        await remove.mutateAsync(id)
        setIsOpenDelete(false)
    }

    return (
        <Wrap>
            {id && isDetailDelivery && <DetailDelivery data={id} isOpen={isDetailDelivery} setOpen={setDetailDelivery} />}
            {isAdd && <CourierAddPages />}
            {isOpenEdit && id && <CourierDetailPages id={id.id} />}
            <DeleteConfirm
                isLoading={remove.isLoading}
                isOpen={isOpenDelete}
                setOpen={() => setIsOpenDelete(false)}
                onClose={() => setIsOpenDelete(false)}
                desc={'kurir'}
                onClick={() => handleDelete(String(id?.id))}
            />

            <SearchInput
                labelBtn="Tambah Kurir"
                link={'/account-courier/add'}
                onClick={() => setOpenAdd(true)}
                placeholder="Cari Kurir"
                onChange={(e) => {
                    setQ(e.target.value)
                }}
            />

            {error ? (
                <PText label={error} />
            ) : (
                <>
                    <Tables
                        columns={column}
                        isLoading={isLoading}
                        data={isLoading ? [] : data?.items || []}
                        usePaging={true}
                        pageH={height}
                    />
                    <PagingButton
                        page={page}
                        nextPage={() => setPage(page + 1)}
                        prevPage={() => setPage(page - 1)}
                        disableNext={data?.next === null}
                    />
                </>
            )}
        </Wrap>
    )
}

export default CourierPages
