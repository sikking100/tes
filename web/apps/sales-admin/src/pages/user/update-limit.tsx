import React from 'react'
import { ButtonForm, Modals, Shared, useToast } from 'ui'
import { userStore } from './user'
import { Flex, Box, Text, Skeleton, Divider, SimpleGrid, Input, HStack, Textarea } from '@chakra-ui/react'
import { Eteam, SelectsTypes } from 'apis'
import { NumericFormat } from 'react-number-format'
import { onCreateNewLimit } from '../business/function'
import Select from 'react-select'
import { customersService, store } from 'hooks'
import { ETeam } from 'apis/services/product/types'
import { findTransaction } from './function'

const UpdateLimit = () => {
    const toast = useToast()
    const [isLoading, setLoading] = React.useState(true)
    const [isLoadingCreateLimit, setLoadingCreateLimit] = React.useState(false)
    const [note, setNote] = React.useState('')
    const users = userStore((v) => v.users)
    const admin = store.useStore((v) => v.admin)
    const isOpen = userStore((v) => v.isOpen)
    const setOpen = userStore((v) => v.setOpen)
    const [team, setTeam] = React.useState<SelectsTypes>()
    const { createApplyNewLimit } = customersService.useCustomer()

    const [transactionLast, setTransactionLast] = React.useState(0)
    const [transactionPer, setTransactionPer] = React.useState(0)
    const [limit, setLimit] = React.useState({
        limit: 0,
        term: 0,
        termInvoice: 0,
    })

    const findTransactions = async () => {
        try {
            const transaction = await findTransaction({ userId: `${users?.id}` })
            setTransactionLast(transaction?.transactionLastMonth || 0)
            setTransactionPer(transaction?.transactionPerMonth || 0)
        } catch (error) {
            console.log(error)
        } finally {
            setLoading(false)
        }
    }

    React.useEffect(() => {
        if (users) {
            findTransactions()
        }
    }, [users])

    const onChangeValue = (e: number, key: string) => {
        setLimit((v) => {
            return {
                ...v,
                [key]: e,
            }
        })
    }

    const onClose = () => setOpen({ isOpen: false, type: undefined })

    return (
        <Modals isOpen={isOpen} setOpen={onClose} size="6xl" title="Update Limit">
            {isLoading ? (
                <Skeleton height={'30px'} />
            ) : (
                <Flex experimental_spaceX={10}>
                    <Box w={'200px'}>
                        <Text fontSize={'sm'}>Transaksi Bulan Lalu</Text>
                        <Text fontWeight={'bold'}>{Shared.formatRupiah(`${transactionLast.toFixed()}`)}</Text>
                    </Box>
                    <Box>
                        <Text fontSize={'sm'}>Transaksi Rata - Rata </Text>
                        <Text fontWeight={'bold'}>{Shared.formatRupiah(`${transactionPer.toFixed()}`)}</Text>
                    </Box>
                </Flex>
            )}
            <Divider my="10px" />
            <Flex experimental_spaceX={10}>
                <Box w={'200px'}>
                    <Text fontSize={'sm'}>Jumlah Limit Digunakan</Text>
                    <Text fontWeight={'bold'}>{Shared.formatRupiah(`${users?.business.credit.used}`)}</Text>
                </Box>
                <Box>
                    <Text fontSize={'sm'}>Limit Sekarang</Text>
                    <Text fontWeight={'bold'}>{Shared.formatRupiah(`${users?.business.credit.limit}`)}</Text>
                </Box>
                <Box>
                    <Text fontSize={'sm'}>Term</Text>
                    <Text fontWeight={'bold'}>{users?.business.credit.term}</Text>
                </Box>
                <Box>
                    <Text fontSize={'sm'}>Term Invoice</Text>
                    <Text fontWeight={'bold'}>{users?.business.credit.termInvoice}</Text>
                </Box>
            </Flex>
            <Divider my="10px" />

            <HStack w={'full'} spacing={6}>
                <Box w="full">
                    <Text style={{ textTransform: 'capitalize' }} fontSize={'sm'} fontWeight={'semibold'}>
                        Tim Approval
                    </Text>
                    <Select
                        isClearable
                        placeholder={'Pilih Tim Approval'}
                        options={[
                            {
                                label: 'FOOD SERVICE',
                                value: `${Eteam.FOOD}`,
                            },
                            {
                                label: 'RETAIL',
                                value: `${ETeam.RETAIL}`,
                            },
                        ]}
                        menuPortalTarget={document.body}
                        styles={{
                            menuPortal: (base) => ({ ...base, zIndex: 9999 }),
                        }}
                        onChange={(e) => {
                            const value = e as SelectsTypes
                            setTeam(value)
                        }}
                    />
                </Box>
            </HStack>

            <Box my="10px" />

            <Box>
                <Text style={{ textTransform: 'capitalize' }} fontSize={'sm'} fontWeight={'semibold'}>
                    Catatan
                </Text>
                <Textarea placeholder="Ketik Catatan" value={note} onChange={(e) => setNote(e.target.value)}></Textarea>
            </Box>

            <Box my="10px" />

            <SimpleGrid columns={3} gap={5}>
                <Box>
                    <Text style={{ textTransform: 'capitalize' }} fontSize={'sm'} fontWeight={'semibold'}>
                        Limit Baru
                    </Text>
                    <NumericFormat
                        value={limit.limit}
                        customInput={Input}
                        placeholder={'Ketik Limit'}
                        thousandSeparator="."
                        decimalSeparator=","
                        prefix="Rp. "
                        onValueChange={(target) => {
                            const val = Number(target.floatValue)
                            onChangeValue(val, 'limit')
                        }}
                    />
                </Box>
                <Box>
                    <Text style={{ textTransform: 'capitalize' }} fontSize={'sm'} fontWeight={'semibold'}>
                        Term Baru
                    </Text>
                    <NumericFormat
                        value={limit.term}
                        customInput={Input}
                        placeholder={'Ketik Term'}
                        onValueChange={(target) => {
                            const val = Number(target.floatValue)
                            onChangeValue(val, 'term')
                        }}
                    />
                </Box>
                <Box>
                    <Text style={{ textTransform: 'capitalize' }} fontSize={'sm'} fontWeight={'semibold'}>
                        Term Invoice Baru
                    </Text>
                    <NumericFormat
                        value={limit.termInvoice}
                        customInput={Input}
                        placeholder={'Ketik Term Invoice'}
                        onValueChange={(target) => {
                            const val = Number(target.floatValue)
                            onChangeValue(val, 'termInvoice')
                        }}
                    />
                </Box>
            </SimpleGrid>

            <ButtonForm
                isLoading={isLoadingCreateLimit}
                type="button"
                label="Ajukan"
                onClose={onClose}
                onClick={() => {
                    if (!users || !team) return
                    const teamL = Number(team.value) as Eteam

                    onCreateNewLimit({
                        toast,
                        adminId: `${admin?.id}`,
                        createApplyNewLimit,
                        onClose: onClose,
                        customers: users,
                        setLoading: setLoadingCreateLimit,
                        rData: {
                            credit: {
                                limit: limit.limit,
                                term: limit.term,
                                termInvoice: limit.termInvoice,
                                used: users?.business.credit.used,
                            },
                            note: note,
                            priceList: {
                                id: users?.business.priceList.id,
                                name: users?.business.priceList.name,
                                createdAt: '',
                                updatedAt: '',
                            },
                            team: teamL,
                            transactionLastMonth: transactionLast,
                            transactionPerMonth: transactionPer,
                            roles: users.business.viewer,
                        },
                    })
                }}
            />
        </Modals>
    )
}

export default UpdateLimit
