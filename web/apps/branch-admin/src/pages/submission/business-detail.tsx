import React from 'react'
import {
    Input,
    Box,
    Divider,
    SimpleGrid,
    Text,
    TabPanel,
    InputGroup,
    InputRightElement,
    IconButton,
    Image,
    VStack,
    Flex,
    HStack,
} from '@chakra-ui/react'
import { GoLocation } from 'react-icons/go'

import {
    Control,
    FormState,
    SubmitHandler,
    useForm,
    UseFormGetValues,
    UseFormHandleSubmit,
    UseFormRegister,
    UseFormSetValue,
} from 'react-hook-form'
import {
    ButtonForm,
    Buttons,
    FormControlNumber,
    FormControls,
    LoadingForm,
    MapsPickLocation,
    Modals,
    PText,
    Shared,
    TabsComponent,
    useToast,
} from 'ui'
import { getCustomerApiInfo, type Address, type CustomerApply } from 'apis'
import { customersService, useDownloadImage } from 'hooks'
import { disclousureStore } from '../../store'

export type ReqTypes = CustomerApply & {
    applyId: string
    newId: string
}

interface setMapsProps {
    idx: number
    type: 'office' | 'shipping'
}

type ReqTypesPosIdCustomer = {
    applyId: string
    newId: string
}

interface Props {
    data?: CustomerApply
    isReadOnly?: boolean
    setValue: UseFormSetValue<ReqTypes>
    register: UseFormRegister<ReqTypes>
    formState: FormState<ReqTypes>
    control: Control<ReqTypes>
    getValues: UseFormGetValues<ReqTypes>
    setLocationShippig: React.Dispatch<React.SetStateAction<Address[]>>
    locationShipping: Address[]
    handleSubmit: UseFormHandleSubmit<ReqTypes>
}

const ProfileUsaha: React.FC<Props> = (props) => {
    const {
        register,
        formState: { errors },
        getValues,
        isReadOnly = true,
    } = props

    return (
        <React.Fragment>
            <SimpleGrid columns={2} gap={10} mt={3}>
                <Box experimental_spaceY={3}>
                    <Box w={'fit-content'} h={'fit-content'}>
                        <Image
                            title="Foto Profile"
                            w={300}
                            h={200}
                            src={getValues('customer.imageUrl') || '/image-thumbnail.png'}
                            objectFit="cover"
                        />
                    </Box>

                    <FormControls
                        readOnly={isReadOnly}
                        label="customer.name"
                        register={register}
                        title={'Nama Pemilik'}
                        errors={errors.customer?.name?.message}
                        required={'Nama tidak boleh kosong'}
                    />

                    <VStack align={'start'}>
                        <Text fontWeight={500} fontSize={'sm'}>
                            Kategori Harga
                        </Text>
                        <Input readOnly value={`${getValues('priceList.name')}`} />
                    </VStack>

                    <FormControls
                        readOnly={isReadOnly}
                        label={'customer.address'}
                        register={register}
                        title={'Alamat Usaha'}
                        errors={errors.customer?.address?.message}
                    />
                </Box>
                <FormControls
                    label="newId"
                    register={register}
                    title={'ID Bisnis'}
                    errors={errors.newId?.message}
                    required={'ID tidak Dapat Kosong'}
                />
            </SimpleGrid>
        </React.Fragment>
    )
}

const ShippingAddressCard: React.FC<Props> = (props) => {
    const { locationShipping, setLocationShippig } = props

    const [idxMaps, setIdxMaps] = React.useState<setMapsProps>({
        idx: 0,
        type: 'shipping',
    })
    const [isOpenMap, setOpenMap] = React.useState(false)

    const setMaps = (i: setMapsProps) => {
        if (i.type === 'shipping') {
            return (
                <MapsPickLocation
                    height="30vh"
                    currentLoc={(e) => {
                        const newArr = locationShipping.map((obj, idx) => {
                            if (idx === i.idx) {
                                return {
                                    lngLat: [e.lat, e.lng],
                                    name: e.address,
                                }
                            }
                            return obj
                        })

                        setLocationShippig(newArr)
                    }}
                />
            )
        }

        return <></>
    }

    return (
        <Box minH={'420px'} maxH={'420px'} overflow={'auto'}>
            {isOpenMap ? <Box mb={1}>{setMaps({ idx: idxMaps.idx, type: idxMaps.type })}</Box> : null}
            <Text textDecor={'underline'} cursor={'pointer'} textAlign={'right'} fontWeight={500} onClick={() => setOpenMap(!isOpenMap)}>
                {isOpenMap ? 'Hide' : 'Show'} Maps
            </Text>
            <SimpleGrid columns={1} gap={4}>
                {locationShipping?.map((i, k) => {
                    return (
                        <React.Fragment key={k}>
                            <InputGroup size="md">
                                <Input
                                    pr="4.5rem"
                                    value={i.name}
                                    defaultValue={i.name}
                                    placeholder={'Ketik Alamat Pengantaran'}
                                    onChange={(e) => {
                                        const newArr = locationShipping?.map((obj, idx) => {
                                            if (idx === k) {
                                                return {
                                                    ...obj,
                                                    address: e.target.value,
                                                }
                                            }
                                            return obj
                                        })
                                        setLocationShippig(newArr)
                                    }}
                                />
                                <InputRightElement width="4.5rem">
                                    <IconButton
                                        h="1.75rem"
                                        aria-label="icon maps"
                                        icon={<GoLocation color={'red'} />}
                                        onClick={() => {
                                            setOpenMap(true)
                                            setIdxMaps({
                                                idx: k,
                                                type: 'shipping',
                                            })
                                        }}
                                    />
                                </InputRightElement>
                            </InputGroup>

                            <Divider />
                        </React.Fragment>
                    )
                })}
            </SimpleGrid>
        </Box>
    )
}

const Pemilik: React.FC<Props> = (props) => {
    const {
        register,
        getValues,
        formState: { errors },
        isReadOnly = true,
    } = props

    React.useEffect(() => {
        Promise.all([useDownloadImage(getValues('customer.idCardPath'))]).then((i) => {
            setImgUrl({ idcard: i[0] })
        })
    }, [getValues('customer.idCardPath')])

    const [imgUrl, setImgUrl] = React.useState({
        idcard: '/image-thumbnail.png',
    })

    return (
        <React.Fragment>
            <SimpleGrid columns={2} gap={10}>
                <Box experimental_spaceY={3}>
                    <Box w={'fit-content'} h={'fit-content'}>
                        <Image title="Foto Usaha" w={300} h={200} src={imgUrl.idcard as string} objectFit="cover" />
                    </Box>

                    <FormControls
                        readOnly={isReadOnly}
                        label="customer.idCardNumber"
                        register={register}
                        title={'NIK'}
                        errors={errors.customer?.idCardNumber?.message}
                        required={'Nik tidak boleh kosong'}
                    />
                    <FormControls
                        readOnly={isReadOnly}
                        label="customer.phone"
                        register={register}
                        title={'Nomor HP'}
                        errors={errors.customer?.phone?.message}
                        required={'Nomor HP tidak boleh kosong'}
                    />
                </Box>
                <Box experimental_spaceY={3}>
                    <FormControls
                        readOnly={isReadOnly}
                        label="customer.email"
                        register={register}
                        title={'Email'}
                        errors={errors.customer?.address?.message}
                    />
                </Box>
            </SimpleGrid>
        </React.Fragment>
    )
}

const Pic: React.FC<Props> = (props) => {
    const {
        register,
        getValues,
        isReadOnly = true,
        formState: { errors },
    } = props

    const [imgUrl, setImgUrl] = React.useState({
        idcard: '/image-thumbnail.png',
    })

    React.useEffect(() => {
        Promise.all([useDownloadImage(getValues('pic.idCardPath'))]).then((i) => {
            setImgUrl({ idcard: i[0] })
        })
    }, [getValues('pic.idCardPath')])

    return (
        <React.Fragment>
            <SimpleGrid columns={2} gap={10}>
                <Box experimental_spaceY={3}>
                    <Box w={'fit-content'} h={'fit-content'}>
                        <Image title="Foto Usaha" w={300} h={200} src={imgUrl.idcard as string} objectFit="cover" />
                    </Box>

                    <FormControls
                        readOnly={isReadOnly}
                        label="pic.idCardNumber"
                        register={register}
                        title={'NIK'}
                        errors={errors.pic?.idCardNumber?.message}
                        required={'Nama tidak boleh kosong'}
                    />
                    <FormControls
                        readOnly={isReadOnly}
                        label="pic.name"
                        register={register}
                        title={'Nama'}
                        errors={errors.pic?.name?.message}
                        required={'Nama tidak boleh kosong'}
                    />
                </Box>
                <Box experimental_spaceY={3}>
                    <FormControls
                        readOnly={isReadOnly}
                        label="pic.phone"
                        register={register}
                        title={'Nomor HP'}
                        errors={errors.pic?.phone?.message}
                        required={'Nomor HP tidak boleh kosong'}
                    />
                    <FormControls
                        readOnly={isReadOnly}
                        label="pic.address"
                        register={register}
                        title={'Alamat'}
                        errors={errors.pic?.address?.message}
                        required={'Alamat tidak boleh kosong'}
                    />
                    <FormControls
                        readOnly={isReadOnly}
                        label="pic.email"
                        register={register}
                        title={'Email'}
                        errors={errors.pic?.phone?.message}
                        required={'Email tidak boleh kosong'}
                    />
                </Box>
            </SimpleGrid>
        </React.Fragment>
    )
}

const Legalitas: React.FC<Props> = (props) => {
    const {
        isReadOnly = true,
        register,
        formState: { errors },
        getValues,
    } = props
    React.useEffect(() => {
        Promise.all([useDownloadImage(getValues('tax.legalityPath'))]).then((i) => {
            setImgUrl({ idcard: i[0] })
        })
    }, [getValues('tax.legalityPath')])

    const [imgUrl, setImgUrl] = React.useState({
        idcard: '/image-thumbnail.png',
    })

    return (
        <React.Fragment>
            <SimpleGrid columns={2} gap={10}>
                <Box experimental_spaceY={3}>
                    <Box w={'fit-content'} h={'fit-content'}>
                        <Image title="Foto Usaha" w={300} h={200} src={imgUrl.idcard as string} objectFit="cover" />
                    </Box>

                    <FormControls
                        readOnly={isReadOnly}
                        label="tax.exchangeDay"
                        register={register}
                        title={'Hari Tukar Faktur (*Jika Berlaku)'}
                        placeholder={'Ketik Hari Tukar Faktur (*Jika Berlaku)'}
                        errors={errors.tax?.exchangeDay?.message}
                    />
                </Box>
            </SimpleGrid>
        </React.Fragment>
    )
}

const LimitTOP: React.FC<Props> = (props) => {
    const {
        register,
        getValues,
        formState: { errors },
        control,
    } = props

    return (
        <React.Fragment>
            <Flex mb="20px" experimental_spaceX={10}>
                <Box>
                    <Text fontSize={'sm'}>Transaksi Bulan Lalu</Text>
                    <Text fontWeight={'bold'}>{Shared.formatRupiah(`$${getValues('transactionLastMonth')}`)}</Text>
                </Box>
                <Box>
                    <Text fontSize={'sm'}>Rata - Rata Transaksi</Text>
                    <Text fontWeight={'bold'}>{Shared.formatRupiah(`$${getValues('transactionPerMonth')}`)}</Text>
                </Box>
            </Flex>
            <Divider mb="10px" />
            <SimpleGrid columns={3} gap={5}>
                <FormControlNumber
                    readOnly={true}
                    control={control}
                    label="creditProposal.limit"
                    register={register}
                    title={'Limit'}
                    placeholder={'Ketik Limit'}
                    errors={errors.creditProposal?.limit?.message}
                />

                <FormControls
                    readOnly={true}
                    control={control}
                    label="creditProposal.term"
                    register={register}
                    title={'Term'}
                    placeholder={'Ketik Term'}
                    errors={errors.creditProposal?.term?.message}
                />
                <FormControls
                    control={control}
                    readOnly={true}
                    label="creditProposal.termInvoice"
                    register={register}
                    title={'Invoice Term'}
                    placeholder={'Ketik Term Invoice'}
                    errors={errors.creditProposal?.termInvoice?.message}
                />
            </SimpleGrid>
        </React.Fragment>
    )
}

export const BusinessDetailApplyPages: React.FC<{ id: string }> = ({ id }) => {
    const setEdit = disclousureStore((v) => v.setIsOpenEdit)
    const isOpenEdit = disclousureStore((v) => v.isOpenEdit)

    const listNavigation = ['Profil Usaha', 'Alamat Pengantaran', 'Pemilik', 'PIC', 'Legalitas', 'TOP']
    const [locationShipping, setLocationShippig] = React.useState<Address[]>([{ name: '', lngLat: [] }])
    const { data, error, isLoading } = customersService.useGetCustomerApplyById(id)
    const { register, control, setValue, reset, getValues, formState, handleSubmit } = useForm<ReqTypes>()
    const { approveBusinessForBranchAdmin } = customersService.useCustomer()

    React.useEffect(() => {
        if (!error && data) {
            reset({
                ...data,
                applyId: data.id,
            })
            setLocationShippig(data.address)
        }
    }, [data, error])

    const onClose = () => setEdit(false)

    const onCreate: SubmitHandler<ReqTypesPosIdCustomer> = async (req) => {
        const ReqData: ReqTypesPosIdCustomer = {
            applyId: getValues('applyId'),
            newId: `${req.newId}`,
        }
        await approveBusinessForBranchAdmin.mutateAsync({
            newId: ReqData.newId,
            applyId: ReqData.applyId,
            note: '',
        })
        onClose()
    }
    const setMt = React.useMemo(() => {
        if (window.screen.availWidth >= 1920) {
            return '-63px'
        }
        if (window.screen.availWidth >= 1535) {
            return '-63px'
        }
        if (window.screen.availWidth >= 1440) {
            return '-63px'
        }
        if (window.screen.availWidth >= 1366) {
            return '-63px'
        }

        return '100%'
    }, [window.screen.availWidth])

    const setHeight = React.useMemo(() => {
        if (window.screen.availWidth >= 1920) {
            return '600px'
        }
        if (window.screen.availWidth >= 1535) {
            return '580px'
        }
        if (window.screen.availWidth >= 1440) {
            return '558px'
        }
        if (window.screen.availWidth >= 1366) {
            return '558px'
        }

        return '100%'
    }, [window.screen.availWidth])

    return (
        <Modals isOpen={isOpenEdit} setOpen={onClose} size={'6xl'} title="Buat ID Bisnis" scrlBehavior="outside">
            {error ? (
                <PText label={error} />
            ) : isLoading ? (
                <LoadingForm />
            ) : (
                <Box h={setHeight}>
                    <TabsComponent TabList={listNavigation} defaultIndex={0} link={'/user/apply/add'} isLazy={false}>
                        <TabPanel px={0}>
                            <ProfileUsaha
                                data={data}
                                control={control}
                                formState={formState}
                                register={register}
                                setValue={setValue}
                                getValues={getValues}
                                setLocationShippig={setLocationShippig}
                                locationShipping={locationShipping}
                                handleSubmit={handleSubmit}
                            />
                        </TabPanel>

                        <TabPanel px={0}>
                            <ShippingAddressCard
                                control={control}
                                formState={formState}
                                register={register}
                                setValue={setValue}
                                getValues={getValues}
                                setLocationShippig={setLocationShippig}
                                locationShipping={locationShipping}
                                handleSubmit={handleSubmit}
                            />
                        </TabPanel>
                        <TabPanel px={0} pt={8}>
                            <Pemilik
                                control={control}
                                formState={formState}
                                register={register}
                                setValue={setValue}
                                getValues={getValues}
                                setLocationShippig={setLocationShippig}
                                locationShipping={locationShipping}
                                handleSubmit={handleSubmit}
                            />
                        </TabPanel>
                        <TabPanel px={0} pt={8}>
                            <Pic
                                control={control}
                                formState={formState}
                                register={register}
                                setValue={setValue}
                                getValues={getValues}
                                setLocationShippig={setLocationShippig}
                                locationShipping={locationShipping}
                                handleSubmit={handleSubmit}
                            />
                        </TabPanel>

                        <TabPanel px={0} pt={8}>
                            <Legalitas
                                control={control}
                                formState={formState}
                                register={register}
                                setValue={setValue}
                                getValues={getValues}
                                setLocationShippig={setLocationShippig}
                                locationShipping={locationShipping}
                                handleSubmit={handleSubmit}
                            />
                        </TabPanel>

                        <TabPanel px={0} pt={8}>
                            <LimitTOP
                                control={control}
                                formState={formState}
                                register={register}
                                setValue={setValue}
                                getValues={getValues}
                                setLocationShippig={setLocationShippig}
                                locationShipping={locationShipping}
                                handleSubmit={handleSubmit}
                            />
                        </TabPanel>
                    </TabsComponent>
                </Box>
            )}

            <Box position={'fixed'} w={'68rem'} mt={setMt}>
                <ButtonForm
                    isLoading={approveBusinessForBranchAdmin.isLoading}
                    label="Simpan"
                    labelClose="Keluar"
                    onClose={() => onClose()}
                    onClick={() => onCreate(getValues())}
                    mt={setMt}
                />
            </Box>
        </Modals>
    )
}
