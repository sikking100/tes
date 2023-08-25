import React from 'react'
import { Box, Divider, SimpleGrid, TabPanel, InputGroup, InputRightElement, Input } from '@chakra-ui/react'
import { Control, FormState, useForm, UseFormGetValues, UseFormRegister, UseFormSetValue } from 'react-hook-form'
import { FormControls, Images, Shared, TabsComponent, entity } from 'ui'
import type { Customers, Address } from 'apis'
import { useDownloadImage } from 'hooks'

type ReqTypes = Customers

interface Props {
    setValue: UseFormSetValue<ReqTypes>
    register: UseFormRegister<ReqTypes>
    formState: FormState<ReqTypes>
    control: Control<ReqTypes>
    getValues: UseFormGetValues<ReqTypes>
    setLocationShippig: React.Dispatch<React.SetStateAction<Address[]>>
    locationShipping: Address[]
}

const ProfileUsaha: React.FC<Props> = (props) => {
    const {
        register,
        formState: { errors },
        getValues,
    } = props

    return (
        <React.Fragment>
            <SimpleGrid columns={2} gap={10} mt={3}>
                <Box w={'fit-content'} h={'fit-content'}>
                    <Images label="Foto Usaha" w={300} h={200} src={getValues('imageUrl')} objectFit="cover" />
                </Box>

                <Box experimental_spaceY={3}>
                    <FormControls
                        readOnly
                        label="name"
                        register={register}
                        title={'Nama'}
                        errors={errors.name?.message}
                        required={'Nama tidak boleh kosong'}
                    />

                    <FormControls
                        readOnly
                        label="business.location.branchName"
                        register={register}
                        title={'Cabang'}
                        required={'Nama tidak boleh kosong'}
                    />

                    <FormControls
                        readOnly
                        label="business.priceList.name"
                        register={register}
                        title={'Kategori Harga'}
                        required={'Nama tidak boleh kosong'}
                    />
                </Box>
            </SimpleGrid>
        </React.Fragment>
    )
}

const ShippingAddressCard: React.FC<Props> = (props) => {
    const { locationShipping, setLocationShippig } = props

    return (
        <React.Fragment>
            <Box experimental_spaceY={3} w={'full'} px={3} overflow={'auto'} mt={4}>
                {locationShipping &&
                    locationShipping.map((i, k) => {
                        return (
                            <React.Fragment key={k}>
                                <InputGroup size="md">
                                    <Input
                                        readOnly
                                        pr="4.5rem"
                                        value={i.name}
                                        placeholder={'Ketik Alamat Pengantaran'}
                                        onChange={(e) => {
                                            const newArr = locationShipping.map((obj, idx) => {
                                                if (idx === k) {
                                                    return { ...obj, address: e.target.value }
                                                }
                                                return obj
                                            })
                                            setLocationShippig(newArr)
                                        }}
                                    />
                                    <InputRightElement width="4.5rem"></InputRightElement>
                                </InputGroup>

                                <Divider />
                            </React.Fragment>
                        )
                    })}
            </Box>
        </React.Fragment>
    )
}

const Pemilik: React.FC<Props> = (props) => {
    const {
        register,
        formState: { errors },
        getValues,
    } = props
    const [imgUrl, setImgUrl] = React.useState({
        idcard: '/default-image.png',
    })

    React.useEffect(() => {
        const control = new AbortController()
        Promise.all([useDownloadImage(getValues('business.customer.idCardPath'))]).then((i) => {
            setImgUrl({ idcard: i[0] })
        })

        return () => control.abort()
    }, [getValues('business')])

    return (
        <React.Fragment>
            <SimpleGrid columns={2} gap={10}>
                <Box experimental_spaceY={3}>
                    <Box w={'fit-content'} h={'fit-content'}>
                        <Images label="Foto Ktp" w={300} h={200} src={imgUrl.idcard} objectFit="cover" />
                    </Box>

                    <FormControls
                        readOnly
                        label="business.customer.idCardNumber"
                        register={register}
                        title={'NIK'}
                        errors={errors.business?.customer?.idCardNumber?.message}
                        required={'Nik tidak boleh kosong'}
                    />
                    <FormControls
                        readOnly
                        label="business.customer.name"
                        register={register}
                        title={'Nama Pemilik'}
                        errors={errors.name?.message}
                        required={'Nama Pemilik tidak boleh kosong'}
                    />
                </Box>
                <Box experimental_spaceY={3}>
                    <FormControls
                        readOnly
                        label="business.customer.phone"
                        register={register}
                        title={'Nomor HP'}
                        errors={errors.phone?.message}
                        required={'Nomor HP tidak boleh kosong'}
                    />
                    <FormControls
                        readOnly
                        label="business.customer.address"
                        register={register}
                        title={'Alamat'}
                        errors={errors.business?.customer?.address?.message}
                        required={'Alamat tidak boleh kosong'}
                    />
                </Box>
            </SimpleGrid>
        </React.Fragment>
    )
}

const Pic: React.FC<Props> = (props) => {
    const { register, getValues } = props
    const [imgUrl, setImgUrl] = React.useState({
        idcard: '/default-image.png',
    })

    React.useEffect(() => {
        const control = new AbortController()
        Promise.all([useDownloadImage(getValues('business.pic.idCardPath'))]).then((i) => {
            setImgUrl({ idcard: i[0] })
        })

        return () => control.abort()
    }, [getValues('business.pic.idCardPath')])

    return (
        <React.Fragment>
            <SimpleGrid columns={2} gap={10}>
                <Box experimental_spaceY={3}>
                    <Box w={'fit-content'} h={'fit-content'}>
                        <Images label="Foto Ktp" w={300} h={200} src={imgUrl.idcard} objectFit="cover" />
                    </Box>

                    <FormControls
                        readOnly
                        label="business.pic.idCardNumber"
                        register={register}
                        title={'NIK'}
                        required={'Nama tidak boleh kosong'}
                    />
                    <FormControls
                        readOnly
                        label="business.pic.name"
                        register={register}
                        title={'Nama'}
                        required={'Nama tidak boleh kosong'}
                    />
                </Box>
                <Box experimental_spaceY={3}>
                    <FormControls
                        readOnly
                        label="business.pic.phone"
                        register={register}
                        title={'Nomor HP'}
                        required={'Nomor HP tidak boleh kosong'}
                    />
                    <FormControls
                        readOnly
                        label="business.pic.address"
                        register={register}
                        title={'Alamat'}
                        required={'Alamat tidak boleh kosong'}
                    />
                    <FormControls
                        readOnly
                        label="business.pic.email"
                        register={register}
                        title={'Email'}
                        required={'Email tidak boleh kosong'}
                    />
                </Box>
            </SimpleGrid>
        </React.Fragment>
    )
}

const Legalitas: React.FC<Props> = (props) => {
    const { register, getValues, setValue } = props
    const [imgUrl, setImgUrl] = React.useState({
        idcard: '/image-thumbnail.png',
    })

    React.useEffect(() => {
        Promise.all([useDownloadImage(getValues('business.tax.legalityPath'))]).then((i) => {
            setImgUrl({ idcard: i[0] })
        })
        setValue('business.tax.exchangeDay', entity.statusTaxDay(getValues('business.tax.exchangeDay')) as unknown as number)
        setValue('business.tax.type', entity.statusTax(getValues('business.tax.type')) as unknown as number)
    }, [getValues('business.tax.legalityPath')])

    return (
        <React.Fragment>
            <SimpleGrid columns={2} gap={10}>
                <Box experimental_spaceY={3}>
                    <Box w={'fit-content'} h={'fit-content'}>
                        <Images label="Foto NPWP" w={300} h={200} src={imgUrl.idcard as string} objectFit="cover" />
                    </Box>

                    <FormControls
                        readOnly
                        label="business.tax.exchangeDay"
                        register={register}
                        title={'Hari Tukar Faktur (*Jika Berlaku)'}
                        placeholder={'Ketik Hari Tukar Faktur (*Jika Berlaku)'}
                    />
                </Box>
                <Box>
                    <FormControls readOnly label="business.tax.type" register={register} title={'Status Pajak (*Jika Berlaku)'} />
                </Box>
            </SimpleGrid>
        </React.Fragment>
    )
}

const LimitTOP: React.FC<Props> = (props) => {
    const { register } = props
    return (
        <React.Fragment>
            <SimpleGrid columns={3} gap={3}>
                <React.Fragment>
                    <FormControls
                        readOnly
                        label="business.credit.limit"
                        register={register}
                        title={'Limit'}
                        placeholder={'Ketik Hari Limit'}
                    />
                    <FormControls
                        readOnly
                        label="business.credit.term"
                        register={register}
                        title={'Term'}
                        placeholder={'Ketik Credit Term'}
                    />
                    <FormControls
                        readOnly
                        label="business.credit.termInvoice"
                        register={register}
                        title={'Invoice Term'}
                        placeholder={'Ketik Invoice Term'}
                    />
                </React.Fragment>
            </SimpleGrid>
        </React.Fragment>
    )
}

export const CustomerDetailBusiness: React.FC<Customers> = (data) => {
    const listNavigation = ['Profil Usaha', 'Alamat Pengantaran', 'Pemilik', 'PIC', 'Legalitas', 'TOP']
    const [locationShipping, setLocationShippig] = React.useState<Address[]>([{ name: '', lngLat: [] }])
    const { register, control, setValue, reset, getValues, formState } = useForm<ReqTypes>()

    React.useEffect(() => {
        reset({
            ...data,
            business: {
                ...data.business,
                customer: {
                    ...data.business.customer,
                    name: data.name,
                    phone: data.phone,
                },
                credit: {
                    ...data.business.credit,
                    // eslint-disable-next-line @typescript-eslint/no-explicit-any
                    limit: Shared.formatRupiah(`${data.business.credit.limit}`) as any,
                },
            },
        })
        setLocationShippig(data.business.address)
    }, [data])

    return (
        <Box h={'500px'}>
            <div>
                <TabsComponent TabList={listNavigation} defaultIndex={0} link={'/customer/apply/add'} isLazy={false}>
                    <TabPanel px={0}>
                        <ProfileUsaha
                            control={control}
                            formState={formState}
                            register={register}
                            setValue={setValue}
                            getValues={getValues}
                            setLocationShippig={setLocationShippig}
                            locationShipping={locationShipping}
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
                        />
                    </TabPanel>
                </TabsComponent>
            </div>
        </Box>
    )
}
