import React from 'react'
import { ButtonTooltip, Icons, InputSearch, PagingButton, PText, Root, Shared, Tables, Types } from 'ui'
import { Customers } from 'apis'
import { HStack, Text } from '@chakra-ui/layout'
import { customersService } from 'hooks'
import { dataListBusiness } from '../../navigation'
import { Avatar } from '@chakra-ui/react'
import CustomerDetailPages from './customer-details'
import { disclousureStore } from '../../store'

const Wrap: React.FC<{ children: React.ReactNode }> = ({ children }) => (
    <Root appName="Branch" items={dataListBusiness} backUrl={'/'} activeNum={1}>
        {children}
    </Root>
)

const CustomerPages = () => {
    const { data, page, isLoading, error, onSetQuerys } = customersService.useGetCustomers()
    const { column, id } = columns()
    const isOpenEdit = disclousureStore((v) => v.isOpenEdit)

    return (
        <Wrap>
            {isOpenEdit && id && <CustomerDetailPages id={id.id} />}
            <HStack w="full" spacing={3} mb={3}>
                <InputSearch
                    text=""
                    placeholder={'Cari Pelanggan ...'}
                    onChange={(e) => {
                        onSetQuerys({
                            search: e.target.value,
                        })
                    }}
                />
            </HStack>
            {error ? (
                <PText label={error} />
            ) : (
                <>
                    <Tables columns={column} isLoading={isLoading} data={isLoading ? [] : data.items} usePaging={true} />
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

export default CustomerPages

const columns = () => {
    // const cols = Columns.columnsUser
    // const [isOpen, setOpen] = React.useState(false)
    const setIsOpenEdit = disclousureStore((v) => v.setIsOpenEdit)

    const [id, setId] = React.useState<Customers>()

    const column: Types.Columns<Customers>[] = [
        {
            header: 'Nama',
            render: (v) => (
                <HStack>
                    <Avatar src={v.imageUrl} />
                    <Text>{v.name}</Text>
                </HStack>
            ),
        },
        {
            header: 'Nomor HP',
            render: (v) => <Text>{v.phone}</Text>,
        },
        {
            header: 'Email',
            render: (v) => <Text>{v.email}</Text>,
        },
        {
            header: 'Status',
            render: (v) => <>{v.business ? 'Bisnis' : 'Walk-In'}</>,
        },
        {
            header: 'Tanggal Dibuat',
            render: (v) => <Text>{Shared.FormatDateToString(v.createdAt)}</Text>,
        },
        {
            header: 'Terakhir Diperbarui',
            render: (v) => <Text>{Shared.FormatDateToString(v.updatedAt)}</Text>,
        },

        {
            header: 'Tindakan',
            render: (v) => (
                <HStack>
                    <ButtonTooltip
                        label={'Detail'}
                        onClick={() => {
                            setIsOpenEdit(true)
                            setId(v)
                        }}
                        icon={<Icons.IconDetails color={'gray'} />}
                    />
                </HStack>
            ),
        },
    ]

    return { column, id }
}
