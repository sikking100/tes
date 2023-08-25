import React from 'react'
import { Tables, SearchInput, Root, PText, DeleteConfirm, PagingButton, TabsComponent } from 'ui'
import { employeeService, store } from 'hooks'
import columnsUser from './users-columns'
import { dataListAccount } from '../../navigation'
import { Divider, TabPanel } from '@chakra-ui/react'
import UserAddPages from './users-add'
import { disclousureStore } from '../../store'
import UserDetailPages from './user-details'
import { useSearchParams, useNavigate } from 'react-router-dom'
import { Eroles } from 'apis'

const Wrap: React.FC<{ children: React.ReactNode }> = ({ children }) => (
    <Root appName="Branch" items={dataListAccount} backUrl={'/'} activeNum={1}>
        {children}
    </Root>
)

const UserComponent: React.FC<{ isRoles: string; s: string; idx: number }> = ({ isRoles, s, idx }) => {
    const admin = store.useStore((i) => i.admin)
    const { data, page, setPage, setQ, error, isLoading } = employeeService.useGetEmployee({
        query: `${isRoles},${admin?.location.id}`,
    })
    const { remove } = employeeService.useEmployee()
    const { column, id } = columnsUser()
    const navigate = useNavigate()

    const isAdd = disclousureStore((v) => v.isAdd)
    const setIsOpenDeelete = disclousureStore((v) => v.setIsOpenDeelete)
    const isOpenDelete = disclousureStore((v) => v.isOpenDelete)
    const isOpenEdit = disclousureStore((v) => v.isOpenEdit)

    const handleDelete = async (id: string) => {
        await remove.mutateAsync(id)
        setIsOpenDeelete(false)
    }

    React.useEffect(() => {
        navigate({ pathname: '/account', search: `idx=${idx}` })
    }, [idx])

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

    React.useEffect(() => {
        if (s) setQ(s)
        else setQ('')
    }, [s])

    return (
        <React.Fragment>
            {isOpenEdit && id && <UserDetailPages id={id.id} />}
            {isAdd && <UserAddPages dRoles={Number(isRoles)} />}
            <Divider />
            <DeleteConfirm
                isLoading={remove.isLoading}
                isOpen={isOpenDelete}
                setOpen={() => setIsOpenDeelete(false)}
                onClose={() => setIsOpenDeelete(false)}
                desc={'User'}
                onClick={() => handleDelete(String(id?.id))}
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
                        pageH={setHeight}
                    />
                    <PagingButton
                        page={page}
                        nextPage={() => setPage(page + 1)}
                        prevPage={() => setPage(page - 1)}
                        disableNext={data?.next === null}
                    />
                </>
            )}
        </React.Fragment>
    )
}
const UserPages = () => {
    const [searchParams] = useSearchParams()
    const [search, setSearch] = React.useState<string>('')
    const setOpenAdd = disclousureStore((v) => v.setOpenAdd)
    const tabList = ['WAREHOUSE ADMIN', 'FINANCE ADMIN', 'SALES ADMIN', 'AREA MANAGER', 'SALES STAF']
    const nums = searchParams.get('idx') ? Number(searchParams.get('idx')) : 0

    return (
        <Wrap>
            <SearchInput
                labelBtn="Tambah Akun"
                link={'/'}
                onClick={() => setOpenAdd(true)}
                placeholder="Cari Akun"
                onChange={(e) => setSearch(e.target.value)}
            />
            <TabsComponent TabList={tabList} defaultIndex={nums} link={'/account'}>
                {[
                    `${Eroles.BRANCH_WAREHOUSE_ADMIN}`,
                    `${Eroles.BRANCH_FINANCE_ADMIN}`,
                    `${Eroles.BRANCH_SALES_ADMIN}`,
                    `${Eroles.AREA_MANAGER}`,
                    `${Eroles.SALES}`,
                ].map((i, idx) => (
                    <TabPanel px={0} key={i}>
                        <UserComponent s={search} isRoles={i} idx={idx} />
                    </TabPanel>
                ))}
            </TabsComponent>
        </Wrap>
    )
}

export default UserPages
