import React from 'react'
import { useForm } from 'react-hook-form'
import { LoadingForm, Modals, PText, Shared } from 'ui'
import { customersService } from 'hooks'
import { Box, SimpleGrid, Text, HStack, Avatar, Divider } from '@chakra-ui/react'
import { CustomerDetailBusiness } from './customer-detail-business'

import type { Customers } from 'apis'
import { disclousureStore } from '../../store'

type ReqTypes = Customers

const CustomerDetailPages: React.FC<{
    id: string
}> = ({ id }) => {
    const [isShowBusiness, setIsShowBusiness] = React.useState(false)
    const { data, error, isLoading } = customersService.useGetCustomerById(`${id}`)
    const setIsOpenEdit = disclousureStore((v) => v.setIsOpenEdit)
    const isOpenEdit = disclousureStore((v) => v.isOpenEdit)

    const { reset, getValues } = useForm<ReqTypes>()

    React.useEffect(() => {
        if (data) {
            reset({ ...data, createdAt: Shared.FormatDateToString(`${data.createdAt}`) })
        }
    }, [data])

    const onClose = () => setIsOpenEdit(false)

    const setMt = React.useMemo(() => {
        if (window.screen.availWidth >= 1920) {
            return '0px'
        }
        if (window.screen.availWidth >= 1535) {
            return '-20px'
        }
        if (window.screen.availWidth >= 1440) {
            return '-20px'
        }
        if (window.screen.availWidth >= 1366) {
            return '-20px'
        }

        return '100%'
    }, [window.screen.availWidth])

    return (
        <Modals isOpen={isOpenEdit} setOpen={onClose} size={'6xl'} title="Detail Pelanggan">
            {error ? (
                <PText label={error} />
            ) : isLoading ? (
                <LoadingForm />
            ) : (
                <React.Fragment>
                    {isShowBusiness ? (
                        <CustomerDetailBusiness {...data} />
                    ) : (
                        <>
                            <HStack align={'start'}>
                                <Avatar src={data.imageUrl} name={data.name} size={'2xl'} />
                                <SimpleGrid columns={2} gap={5} w="full">
                                    <Box w="full">
                                        <Text fontSize={'sm'} fontWeight={'bold'}>
                                            ID
                                        </Text>
                                        <Text textTransform={'capitalize'}>{data.id}</Text>
                                        <Divider />
                                    </Box>
                                    <Box w="full">
                                        <Text fontSize={'sm'} fontWeight={'bold'}>
                                            Nama
                                        </Text>
                                        <Text textTransform={'capitalize'}>{data.name.toLowerCase()}</Text>
                                        <Divider />
                                    </Box>
                                    <Box w="full">
                                        <Text fontSize={'sm'} fontWeight={'bold'}>
                                            Email
                                        </Text>
                                        <Text>{data.email}</Text>
                                        <Divider />
                                    </Box>
                                    <Box w="full">
                                        <Text fontSize={'sm'} fontWeight={'bold'}>
                                            Nomor HP
                                        </Text>
                                        <Text textTransform={'capitalize'}>{data.phone}</Text>
                                        <Divider />
                                    </Box>
                                    <Box w="full">
                                        <Text fontSize={'sm'} fontWeight={'bold'}>
                                            Jenis Pelanggan
                                        </Text>
                                        <Text textTransform={'capitalize'}>{data.business ? 'Bisnis' : 'Walk-In'}</Text>
                                        <Divider />
                                    </Box>
                                </SimpleGrid>
                            </HStack>
                        </>
                    )}

                    <>
                        {getValues('business') && (
                            <Text
                                textDecor={'underline'}
                                cursor={'pointer'}
                                fontWeight={'semibold'}
                                mt={isShowBusiness ? setMt : '0px'}
                                onClick={() => setIsShowBusiness(!isShowBusiness)}
                            >
                                Lihat {isShowBusiness ? 'Kembali' : 'Detail Bisnis'}
                            </Text>
                        )}
                    </>
                </React.Fragment>
            )}
        </Modals>
    )
}

export default CustomerDetailPages
