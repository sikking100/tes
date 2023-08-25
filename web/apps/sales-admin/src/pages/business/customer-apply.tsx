import React from 'react'
import { customersService, store } from 'hooks'
import { CustomerApply, TypeCustomerApply } from 'apis'
import { ButtonTooltip, entity, Icons, PagingButton, PText, Root, StackAvatar, Tables, TabsComponent, Types } from 'ui'
import { Text } from '@chakra-ui/layout'
import { dataListUser } from '~/navigation'
import { BusinessDetailApplyPages } from './customer-detail-apply'
import { TabPanel } from '@chakra-ui/react'
import { TypeDetailCustomer, userStore } from '../user/user'
import { useNavigate, useSearchParams } from 'react-router-dom'

const Wrap: React.FC<{ children: React.ReactNode }> = ({ children }) => (
    <Root appName="Sales" items={dataListUser} backUrl={'/'} activeNum={2}>
        {children}
    </Root>
)

const CustomerApplyC: React.FC<{ type: number }> = ({ type }) => {
    const admin = store.useStore((v) => v.admin)
    const isOpen = userStore((v) => v.isOpen)
    const navigate = useNavigate()

    const { data, error, isLoading, setPage, page } = customersService.useGetCustomerApply({
        type,
        userId: `${admin?.id}`,
    })
    const { column, data: id } = columns()

    React.useEffect(() => {
        navigate({ pathname: '/customer-apply', search: `type=${type}` })
    }, [type])

    return (
        <>
            {isOpen && id && <BusinessDetailApplyPages id={id.id} />}
            {error ? (
                <PText label={error} />
            ) : (
                <Tables columns={column} data={isLoading ? [] : data.items} isLoading={isLoading} useTab={true} />
            )}
            <PagingButton
                page={page}
                nextPage={() => setPage(page + 1)}
                prevPage={() => setPage(page - 1)}
                disableNext={data?.next === null}
            />
        </>
    )
}

const CustomerApplyPages = () => {
    const listNavigation = ['MENUNGGU PERSETUJUAN', 'SEMUA']
    const [query] = useSearchParams()

    const defaultIdx = (): number => {
        const q = query.get('type') as string
        if (parseInt(q) === TypeCustomerApply.WAITING_APPROVE) {
            return 0
        }
        if (parseInt(q) === TypeCustomerApply.ALL) {
            return 1
        }
        return 0
    }

    return (
        <Wrap>
            <TabsComponent TabList={listNavigation} defaultIndex={defaultIdx()}>
                <TabPanel px={0}>
                    <CustomerApplyC type={TypeCustomerApply.WAITING_LIMIT} />
                </TabPanel>
                <TabPanel px={0}>
                    <CustomerApplyC type={TypeCustomerApply.ALL} />
                </TabPanel>
            </TabsComponent>
        </Wrap>
    )
}

function columns() {
    const setUser = userStore((v) => v.setUser)
    const [data, setData] = React.useState<CustomerApply>()
    const setOpen = userStore((v) => v.setOpen)

    const column: Types.Columns<CustomerApply>[] = [
        {
            header: 'Nama Pemilik',
            render: (v) => <StackAvatar name={v.customer.name} imageUrl={v.customer.imageUrl} />,
        },

        {
            header: 'Nama PIC',
            render: (v) => <Text>{v.pic.name}</Text>,
        },
        {
            header: 'Lokasi',
            render: (v) => <Text>{v.location.branchName}</Text>,
        },
        {
            header: 'Status',
            render: (v) => <Text>{entity.checkStatusCustomerApply({ status: v.status, type: v.type })}</Text>,
        },
        {
            header: 'Jenis Pengajuan',
            render: (v) => <Text>{entity.typeApply(v.type)}</Text>,
        },
        {
            header: 'Cabang',
            render: (v) => <Text>{v.location.branchName}</Text>,
        },
        {
            header: 'Tindakan',
            render: (v) => {
                return (
                    <ButtonTooltip
                        label={'Detail'}
                        icon={<Icons.IconDetails color={'gray'} />}
                        onClick={() => {
                            setUser(v)
                            setData(v)
                            setOpen({
                                isOpen: true,
                                type: TypeDetailCustomer.DETAIL_BUSINESS_APPLY,
                            })
                        }}
                    />
                )
            },
        },
    ]

    return { column, data, setData }
}

export default CustomerApplyPages
