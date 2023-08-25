import React from 'react'
import { create } from 'zustand'
import { ButtonTooltip, Columns, Icons, PagingButton, PText, Root, SearchInput, Tables, Types } from 'ui'
import { CustomerApply, Customers, Eroles } from 'apis'
import { customersService, store } from 'hooks'
import { dataListUser } from '~/navigation'
import { CustomerCreateApplyPages } from '../business/customer-detail-apply'
import { HStack } from '@chakra-ui/layout'
import DetailCustomer from './user-detail'
import UpdateLimit from './update-limit'

export enum TypeDetailCustomer {
    DETAIL_BUSINESS = 'DETAIL_BUSINESS',
    DETAIL_BUSINESS_APPLY = 'DETAIL_BUSINESS_APPLY',
    UPDATE_LIMIT = 'UPDATE_LIMIT',
    CREATE = 'CREATE',
    CREATE_W_EXIST = 'CREATE_W_EXIST',
}

interface IStore {
    user?: CustomerApply | undefined
    setUser: (v: CustomerApply | undefined) => void
    users?: Customers
    setUsers: (v?: Customers | undefined) => void
    isOpen: boolean
    type?: TypeDetailCustomer
    setOpen: (req: { type?: TypeDetailCustomer; isOpen: boolean }) => void
}

export const userStore = create<IStore>((set) => ({
    user: undefined,
    users: undefined,
    type: undefined,
    isOpen: false,
    setUsers: (v) => {
        set({
            users: v,
        })
    },
    setUser: (v) => set({ user: v }),
    setOpen: (v) => set({ ...v }),
}))

const Wrap: React.FC<{ children: React.ReactNode }> = ({ children }) => (
    <Root appName="Sales" items={dataListUser} backUrl={'/'} activeNum={1}>
        {children}
    </Root>
)

const UserPages = () => {
    const users = userStore((v) => v.users)
    const type = userStore((v) => v.type)
    const setOpen = userStore((v) => v.setOpen)
    const isOpen = userStore((v) => v.isOpen)
    const admin = store.useStore((v) => v.admin)
    const { column, id } = columnsUser()
    const { data, page, error, isLoading, onSetQuerys } = customersService.useGetCustomers()

    const isCreate = type === TypeDetailCustomer.CREATE || type === TypeDetailCustomer.CREATE_W_EXIST

    React.useEffect(() => {
        if (admin && admin.roles === Eroles.BRANCH_SALES_ADMIN) {
            onSetQuerys({
                branchId: admin.location.id,
            })
        }
    }, [admin])

    return (
        <Wrap>
            {isOpen && id && <DetailCustomer customerId={id.id} />}
            {isOpen && isCreate && (
                <CustomerCreateApplyPages isOpens={isOpen} setOpen={() => setOpen({ isOpen: false, type: undefined })} />
            )}
            {isOpen && users && type === TypeDetailCustomer.UPDATE_LIMIT && <UpdateLimit />}
            <SearchInput
                placeholder="Cari Pelanggan"
                onChange={(e) => onSetQuerys({ search: e.target.value })}
                onClick={() => setOpen({ isOpen: true, type: TypeDetailCustomer.CREATE })}
                link="/"
            />
            {error ? (
                <PText label={error} />
            ) : (
                <>
                    <Tables columns={column} data={isLoading ? [] : data.items} isLoading={isLoading} />
                    <PagingButton
                        page={Number(page)}
                        nextPage={() => onSetQuerys({ page: Number(page) + 1 })}
                        prevPage={() => onSetQuerys({ page: Number(page) - 1 })}
                        disableNext={data?.next === null}
                    />
                </>
            )}
        </Wrap>
    )
}

export default UserPages

const columnsUser = () => {
    const setOpen = userStore((v) => v.setOpen)
    const setUsers = userStore((v) => v.setUsers)

    const [id, setId] = React.useState<Customers>()
    const [isOpenDetail, setOpenDetail] = React.useState(false)
    const cols = Columns.columnsUser

    const column: Types.Columns<Customers>[] = [
        cols.name,
        cols.phone,
        cols.email,
        {
            header: 'Status',
            render: (v) => <>{v.business ? 'Bisnis' : 'Walk-In'}</>,
        },
        {
            header: 'Tindakan',
            render: (v) => (
                <HStack>
                    <ButtonTooltip
                        label={'Detail'}
                        icon={<Icons.IconDetails color={'gray'} />}
                        onClick={() => {
                            setOpen({ isOpen: true, type: undefined })
                            setId(v)
                            setUsers(v)
                        }}
                    />
                    <ButtonTooltip
                        isDisabled={!!v.business}
                        label={'Tambah Bisnis'}
                        icon={<Icons.AddIcons color={'gray'} />}
                        onClick={() => {
                            setOpen({ isOpen: true, type: TypeDetailCustomer.CREATE_W_EXIST })
                            setUsers(v)
                            setId(v)
                        }}
                    />
                    <ButtonTooltip
                        isDisabled={!v.business}
                        label={'Ubah Limit'}
                        icon={<Icons.IconReload color={'gray'} />}
                        onClick={() => {
                            setOpen({ isOpen: true, type: TypeDetailCustomer.UPDATE_LIMIT })
                            setUsers(v)
                            setId(v)
                        }}
                    />
                </HStack>
            ),
        },
    ]

    return {
        column,
        isOpenDetail,
        setOpenDetail,
        id,
    }
}
