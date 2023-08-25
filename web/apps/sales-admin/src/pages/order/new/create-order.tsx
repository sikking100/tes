import React from 'react'
import { useNavigate } from 'react-router-dom'
import {
    Buttons,
    FormControls,
    FormControlsTextArea,
    FormSelects,
    LoadingForm,
    Modals,
    PText,
    PagingButton,
    Root,
    Shared,
    StackAvatar,
    Tables,
    entity,
    useToast,
} from 'ui'
import { orderService, productService, store, usePickImage } from 'hooks'
import {
    Address,
    Code,
    CourierType,
    CreateOrder,
    Customers,
    EPaymentMethod,
    EmployeeApprover,
    Eroles,
    Eteam,
    PriceProducts,
    getEmployeeApiInfo,
} from 'apis'
import { useForm } from 'react-hook-form'
import {
    HStack,
    Box,
    Text,
    Divider,
    SimpleGrid,
    VStack,
    Image,
    Radio,
    RadioGroup,
    Input,
    IconButton,
    InputGroup,
    InputLeftAddon,
    Spinner,
    Center,
    useRadio,
    useRadioGroup,
    Skeleton,
    UnorderedList,
    ListItem,
} from '@chakra-ui/react'
import { AddIcon, MinusIcon, Search2Icon } from '@chakra-ui/icons'
import { useStoreSteps } from '~/store'
import StepsTimeLine from '~/components/steps'
import { IReqOrderReq, IState, RenderBusinessProps, SummaryProps } from './types'
import { Product } from 'apis/services/product/types'
import { branchSearch, codeSearch, customerSearchByBranch, schemaCreateOrder } from './function'
import { TextTitle } from './card-detail-info-order'
import { formatRupiah } from 'ui/src/utils/shared'
import { FilterProduct } from './filter-product'
import { CreateProductOrder } from 'apis/services/order/order'
import { findTransaction } from '~/pages/user/function'
// import ReactRouterPrompt from 'react-router-prompt'
import { ZodError } from 'zod'
import { reOrderState } from './my-order'

const Wrap: React.FC<{ children: React.ReactNode }> = ({ children }) => {
    const dataListOrder = [
        {
            id: 1,
            link: '/order',
            title: 'Pesanan',
        },
        {
            id: 2,
            link: '/order-me',
            title: 'Buat Pesanan',
        },
    ]
    return (
        <Root appName="Sales" items={dataListOrder} backUrl={'/order'} activeNum={2}>
            {children}
        </Root>
    )
}

const initialState: IState = {
    customers: {} as Customers,
    address: [] as Address[],
    addressShipp: {} as Address,
    totalPrice: 0,
    ongkir: 0,
    additionalDiscount: 0,
    addDiscount: {},
    productCheckout: [] as CreateProductOrder[],
    isLoadingCreate: false,
}
interface AddsDiscount {
    [key: string]: number
}

const AppContext = React.createContext<{
    state: IState
    dispatch: React.Dispatch<IState>
}>({
    state: initialState,
    dispatch: () => null,
})

function timeout(ms: number) {
    return new Promise((resolve) => setTimeout(resolve, ms))
}

const Providers: React.FC<{ children: React.ReactNode }> = ({ children }) => {
    const reOrder = reOrderState((i) => i.order)

    const [state, dispatch] = React.useReducer((state: IState, newState: Partial<IState>) => {
        const minPriceOngkir = 500000

        const newEvent = { ...state, ...newState }

        const priceTotal = newEvent.productCheckout
            ?.map((i) => {
                const num1 = Number(i.unitPrice) * i.qty
                const disc = i.discount + Number(i?.additional || 0)
                const num2 = num1 - disc
                i.totalPrice = num1 - i.discount
                i.finalPrice_ = num2
                return num2
            })
            .reduce((partial, a) => partial + a, 0)

        if (Number(newEvent.ongkir) > 0 && Number(priceTotal) > minPriceOngkir) {
            newEvent.totalPrice = Number(priceTotal) - Number(newEvent.ongkir)
            newEvent.ongkir = 0
        } else if (Number(newEvent.ongkir) > 0) {
            newEvent.totalPrice = Number(priceTotal) + Number(newEvent.ongkir)
        } else {
            newEvent.totalPrice = priceTotal
        }

        // const finalPrice = newEvent.productCheckout?.reduce((a, b) => a + b.totalPrice - Number(b?.additional || 0), 0)
        newEvent.totalPrice = priceTotal

        console.log('newEvent', newEvent)

        return newEvent
    }, initialState)

    React.useEffect(() => {
        if (!reOrder) {
            dispatch(initialState)
        }
    }, [reOrder])

    return <AppContext.Provider value={{ state, dispatch }}>{children}</AppContext.Provider>
}

const LoadingCheckout: React.FC<{ isLoading: boolean }> = ({ isLoading }) => {
    return (
        <Modals isOpen={isLoading} setOpen={() => undefined} size="sm">
            <Center bg={'white'} h={'150px'}>
                <Spinner thickness="8px" speed="1s" emptyColor="gray.200" color="red.200" width={'100px'} height={'100px'} />
            </Center>
        </Modals>
    )
}

const RenderBusiness = () => {
    const [isNextDisable, setNextDisable] = React.useState(true)
    const setDisabelNext = useStoreSteps((v) => v.setDisabelNext)
    const { state } = React.useContext(AppContext)

    React.useEffect(() => {
        if (state.customers) {
            if (!isNextDisable) setDisabelNext(false)
            else setDisabelNext(false)
            setNextDisable(false)
        } else {
            setDisabelNext(true)
        }
    }, [state.customers])

    if (!state.customers) return <LoadingForm />

    return (
        <SimpleGrid columns={5} mt={5} gap={5}>
            <Box>
                <Image src={state.customers.imageUrl} rounded={'md'} objectFit={'cover'} w={'300px'} h={'200px'} />
            </Box>
            <SimpleGrid columns={2} gridColumnStart={2} gridColumnEnd={5}>
                <Box w={'50%'} experimental_spaceY={3}>
                    <TextTitle title="Nama Usaha" val={state.customers.name} />
                    <TextTitle title="Nama PIC" val={state.customers?.business?.pic?.name} />
                    <TextTitle title="Alamat" val={state.customers.business?.pic?.address} />
                    <TextTitle title="Nomor HP" val={state.customers.business?.pic?.phone} />
                </Box>
                <Box experimental_spaceY={3}>
                    <TextTitle title="Email" val={state.customers.email} />
                    <TextTitle title="Kategori Harga" val={state.customers.business?.priceList.name} />
                    <TextTitle title="Cabang" val={state.customers.business?.location.branchName} />
                </Box>
            </SimpleGrid>
        </SimpleGrid>
    )
}

const ShippingAddress: React.FC<RenderBusinessProps> = () => {
    const { state, dispatch } = React.useContext(AppContext)
    const [isNextDisable, setNextDisable] = React.useState(true)
    const setDisabelNext = useStoreSteps((v) => v.setDisabelNext)
    const { getRadioProps, value } = useRadioGroup({
        name: 'shipping',
        defaultValue: '',
        onChange: (e) =>
            dispatch({
                addressShipp: JSON.parse(e) as Address,
            }),
    })

    React.useEffect(() => {
        if (value) {
            if (!isNextDisable) setDisabelNext(false)
            else setDisabelNext(false)
            setNextDisable(false)
        } else setDisabelNext(true)
    }, [value])

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    function RadioCard(props: any) {
        const { getInputProps, getCheckboxProps } = useRadio({
            ...props,
        })
        const input = getInputProps()
        const checkbox = getCheckboxProps()

        return (
            <Box as="label">
                <input {...input} />
                <Box
                    {...checkbox}
                    cursor="pointer"
                    borderWidth="1px"
                    borderRadius="md"
                    boxShadow="md"
                    _checked={{
                        bg: 'red.200',
                        color: 'white',
                        borderColor: 'white',
                    }}
                    _focus={{
                        boxShadow: 'outline',
                    }}
                    px={5}
                    py={3}
                >
                    {props.children}
                </Box>
            </Box>
        )
    }

    return (
        <Box h={'370px'} mt={'20px'}>
            <SimpleGrid columns={1} gap={4}>
                {state.customers?.business?.address?.map((data) => {
                    const radio = getRadioProps({
                        value: `${JSON.stringify(data)}`,
                    })
                    return (
                        <RadioCard key={data.name} {...radio}>
                            {data.name}
                        </RadioCard>
                    )
                })}
            </SimpleGrid>
        </Box>
    )
}

const RenderProduct: React.FC = () => {
    const priceOfProduct = new PriceProducts()
    const toast = useToast()
    const { state, dispatch } = React.useContext(AppContext)
    const [isOpenFilter, setOpenFilter] = React.useState(false)
    const [isNextDisable, setNextDisable] = React.useState(true)
    const setDisabelNext = useStoreSteps((v) => v.setDisabelNext)
    const [isLoadingPrice, setLoadingPrice] = React.useState(false)
    const { data, error, isLoading, onSetQuerys, querys, onSetPage } = productService.useGetProductBranch()
    const [selectIdProduct, setSelectIdProduct] = React.useState('')

    React.useEffect(() => {
        onSetQuerys({
            branchId: `${state.customers?.business.location.branchId}`,
        })
    }, [])

    React.useEffect(() => {
        if (Number(state.productCheckout?.length) >= 1) {
            if (!isNextDisable) setDisabelNext(false)
            setDisabelNext(false)
            setNextDisable(false)
        } else {
            setDisabelNext(true)
            setNextDisable(true)
        }
    }, [state.productCheckout])

    React.useEffect(() => {
        state.productCheckout?.find((e) => e.qty === 0) &&
            dispatch({
                productCheckout: state.productCheckout.filter((e) => e.qty !== 0),
            })
    }, [state.productCheckout])

    React.useEffect(() => {
        if (Number(state.totalPrice) > 500000) dispatch({ ongkir: 0 })
    }, [state.totalPrice])

    const Discount = (prod: Product, qty: number) => {
        let d = 0
        const priceList = state.customers?.business?.priceList?.id
        const findpriceList = prod.price?.find((i) => i.id === priceList)
        const disco = findpriceList?.discount || null
        if (disco === null) {
            d = 0
        } else if (findpriceList) {
            disco.forEach((i) => {
                const expiredAt = new Date(i.expiredAt || '')
                const startAt = new Date(i.startAt || '')

                if (startAt < new Date() && expiredAt > new Date() && qty >= i.min) {
                    if (i.max === null) {
                        d = i.discount * qty
                    } else if (i.max !== null && qty > i.max) {
                        d = 0
                    } else if (i.max !== null && qty <= i.max) {
                        d = i.discount * qty
                    }
                }
            })
        }

        return d
    }

    const onSetProductInChart = React.useCallback(
        async (prod: Product, qty: number, ons: boolean) => {
            if (qty === 0) return
            setSelectIdProduct(prod.productId)
            setLoadingPrice(true)

            await timeout(400)

            const prodExist = state.productCheckout?.find((i) => i.id === prod.productId)

            if (prodExist) {
                if (prodExist.qty === 0) {
                    setLoadingPrice(false)
                    return
                }
                if (!ons) {
                    if (qty < 0) {
                        if (prodExist.qty === 1) {
                            dispatch({
                                addDiscount: {},
                            })
                        }
                        prodExist.qty += qty
                        prodExist.discount = Discount(prod, prodExist.qty)
                        dispatch({
                            productCheckout: [...(state.productCheckout !== undefined ? state.productCheckout : [])],
                        })
                        setLoadingPrice(false)
                        return
                    }

                    prodExist.qty += qty
                    prodExist.discount = Discount(prod, prodExist.qty)

                    dispatch({
                        productCheckout: [...(state.productCheckout !== undefined ? state.productCheckout : [])],
                    })
                    setLoadingPrice(false)
                }
                if (ons) {
                    prodExist.qty = qty
                    prodExist.discount = Discount(prod, prodExist.qty)

                    dispatch({
                        productCheckout: [...(state.productCheckout !== undefined ? state.productCheckout : [])],
                    })
                }
                setLoadingPrice(false)
                return
            }

            if (prod) {
                const pList = state.customers?.business?.priceList.id
                const datProduct: CreateProductOrder = {
                    id: prod.productId,
                    name: prod.name,
                    description: prod.description,
                    qty: qty,
                    team: prod.category.team,
                    discount: priceOfProduct.getDiscount({
                        idPriceList: `${pList}`,
                        qty: qty,
                        priceList: prod.price,
                    }),
                    brandId: prod.brand.id,
                    brandName: prod.brand.name,
                    categoryId: prod.category.id,
                    categoryName: prod.category.name,
                    point: prod.point,
                    totalPrice: priceOfProduct.getDiscount({
                        idPriceList: `${pList}`,
                        qty: qty,
                        priceList: prod.price,
                    }),
                    imageUrl: prod.imageUrl,
                    tax: 0,
                    unitPrice: priceOfProduct.getPriceOfProduct({
                        idPriceList: `${pList}`,
                        priceList: prod.price,
                        qty: 1,
                    }),
                    salesId: prod.salesId,
                    salesName: prod.salesName,
                    size: prod.size,
                    additional: 0,
                    countAdditional: 0,
                }
                datProduct.qty = qty
                datProduct.discount = Discount(prod, datProduct.qty)
                dispatch({
                    productCheckout: [...(state.productCheckout !== undefined ? state.productCheckout : []), datProduct],
                })
            }
            setLoadingPrice(false)
        },
        [state.productCheckout]
    )

    const isDisabledQty = (id: string) => {
        const res = state.productCheckout?.find((v) => v.id === id)?.qty
        if (res) {
            return res === 0
        }
        return true
    }

    const onSetAdditionalDiscount = async (idProduct: string, dis: number, ons?: boolean) => {
        let priceDiscount = 0

        setLoadingPrice(true)
        if (dis > 100) {
            setLoadingPrice(false)
            return
        }
        if (dis < 0 && ons) {
            setLoadingPrice(false)
            return
        }

        const addDiscount = state.addDiscount as AddsDiscount
        const prodExist = state.productCheckout?.find((i) => i.id === idProduct)
        if (!prodExist) {
            toast({
                status: 'error',
                description: 'Pastikan telah memasukkan kuantity produk',
            })
            setLoadingPrice(false)

            return
        }

        if (prodExist) {
            if (dis < 0 && Number(prodExist.countAdditional) === 0 && !ons) {
                setLoadingPrice(false)
                return
            }
        }

        if (Object.keys(addDiscount).find((i) => i === idProduct)) {
            if (!ons) {
                priceDiscount = addDiscount[idProduct] += parseInt(`${dis}`)
            }
            if (ons && dis !== -1) {
                priceDiscount = parseInt(`${dis}`)
            }

            dispatch({
                addDiscount: {
                    ...state.addDiscount,
                    [idProduct]: priceDiscount,
                },
            })
        } else {
            if (dis < 0) {
                setLoadingPrice(false)
                return
            }
            priceDiscount = dis
            dispatch({
                addDiscount: {
                    ...state.addDiscount,
                    [idProduct]: priceDiscount,
                },
            })
        }
        await timeout(400)

        if (prodExist) {
            const calculateDiscount = priceDiscount * prodExist.totalPrice
            const price = calculateDiscount / 100

            prodExist.additional = price
            prodExist.countAdditional = priceDiscount
            dispatch({
                productCheckout: [...(state.productCheckout !== undefined ? state.productCheckout : [])],
            })
        }
        setLoadingPrice(false)
    }

    const setHeight = () => {
        if (window.screen.availWidth >= 1920) {
            return '62vh'
        }
        if (window.screen.availWidth >= 1535) {
            return '51vh'
        }
        if (window.screen.availWidth >= 1440) {
            return '51vh'
        }
        if (window.screen.availWidth >= 1366) {
            return '46vh'
        }

        return '100%'
    }

    return (
        <Box pt={2}>
            <Divider />
            <HStack justifyContent={'space-between'} py={3}>
                <HStack>
                    <InputGroup>
                        <InputLeftAddon>
                            <Search2Icon />
                        </InputLeftAddon>
                        <Input
                            placeholder="Cari Produk"
                            w={'500px'}
                            onChange={(e) => onSetQuerys({ search: e.target.value })}
                            width={'100px'}
                        />
                    </InputGroup>
                    <FilterProduct isOpen={isOpenFilter} onOpen={setOpenFilter} onSetQuerys={onSetQuerys} />
                </HStack>
                <HStack w={'full'} textAlign={'right'} top={0} right={0} justify={'flex-end'}>
                    <Text>Total Belanja</Text>
                    {isLoadingPrice ? (
                        <Skeleton height="20px" w={'100px'} />
                    ) : (
                        <Text textAlign={'right'} fontWeight={'semibold'} fontSize={'lg'}>
                            {Shared.formatRupiah(`${state.totalPrice}`)}
                        </Text>
                    )}
                </HStack>
            </HStack>

            <Divider />

            {error ? (
                <PText label={error} />
            ) : (
                <Box mb={4}>
                    <Tables
                        pageH={setHeight()}
                        data={isLoading ? [] : data.items}
                        isLoading={isLoading}
                        usePaging={true}
                        columns={[
                            {
                                header: 'ID Produk',
                                render: (i) => <Text>{i.id}</Text>,
                            },
                            {
                                header: 'Produk',
                                render: (i) => <StackAvatar imageUrl={i.imageUrl} name={i.name} />,
                            },
                            {
                                header: 'Brand',
                                render: (i) => <StackAvatar imageUrl={i.brand.imageUrl} name={i.brand.name} />,
                            },
                            {
                                header: 'Kategori',
                                render: (i) => (
                                    <Text>
                                        {i.category.name} - {entity.team(`${i.category.team}`)}
                                    </Text>
                                ),
                            },
                            {
                                header: 'Ukuran',
                                render: (i) => <Text>{i.size}</Text>,
                            },
                            {
                                header: 'Harga',
                                render: (i) => (
                                    <Text>
                                        {formatRupiah(
                                            `${priceOfProduct.getPriceOfProduct({
                                                idPriceList: `${state.customers?.business.priceList.id}`,
                                                priceList: i.price,
                                                qty: 0,
                                            })}`
                                        )}
                                    </Text>
                                ),
                            },
                            {
                                header: 'Strata',
                                render: (i) => (
                                    <Box w={'150px'}>
                                        {priceOfProduct
                                            .getStrataOfProduct({
                                                idPriceList: `${state.customers?.business.priceList.id}`,
                                                priceList: i.price,
                                                qty: 0,
                                            })
                                            ?.discount.map((v, k) => {
                                                const exp = new Date() > new Date(v.expiredAt)
                                                return (
                                                    <UnorderedList key={k}>
                                                        <ListItem>
                                                            <Text as={exp ? 'del' : 'p'}>
                                                                Min {v.min}, Max {v.max || '-'} .{formatRupiah(String(v.discount))}
                                                            </Text>
                                                        </ListItem>
                                                    </UnorderedList>
                                                )
                                            })}
                                    </Box>
                                ),
                            },
                            {
                                header: 'Diskon %',
                                render: (v) => {
                                    const find = state?.productCheckout?.find((it) => it.id === v.productId)
                                    return (
                                        <HStack spacing={0}>
                                            <IconButton
                                                rounded={'none'}
                                                borderLeftRadius={'8px'}
                                                bg="black"
                                                size={'sm'}
                                                aria-label="Search database"
                                                icon={<MinusIcon fontSize={'10px'} />}
                                                onClick={() => onSetAdditionalDiscount(v.productId, -1)}
                                            />
                                            <Input
                                                placeholder="0"
                                                type="number"
                                                w={'50px'}
                                                fontSize={'sm'}
                                                textAlign={'center'}
                                                size={'sm'}
                                                onChange={(e) => {
                                                    const p = Number(e.target.value)
                                                    onSetAdditionalDiscount(v.productId, p, true)
                                                }}
                                                value={find?.countAdditional || 0}
                                            />

                                            <IconButton
                                                rounded={'none'}
                                                bg="black"
                                                size={'sm'}
                                                borderRightRadius={'8px'}
                                                aria-label="Search database"
                                                icon={<AddIcon fontSize={'10px'} />}
                                                onClick={() => onSetAdditionalDiscount(v.productId, 1)}
                                            />
                                        </HStack>
                                    )
                                },
                            },
                            {
                                header: 'Jumlah',
                                render: (i) => (
                                    <HStack spacing={0}>
                                        <IconButton
                                            isDisabled={isDisabledQty(i.productId)}
                                            rounded={'none'}
                                            borderLeftRadius={'8px'}
                                            bg="black"
                                            size={'sm'}
                                            aria-label="Search database"
                                            onClick={() => onSetProductInChart(i, -1, false)}
                                            icon={<MinusIcon fontSize={'10px'} />}
                                        />
                                        <Input
                                            value={state.productCheckout?.find((v) => v.id === i.productId)?.qty}
                                            type={'number'}
                                            placeholder="0"
                                            w={'50px'}
                                            fontSize={'sm'}
                                            textAlign={'center'}
                                            size={'sm'}
                                            onChange={(e) => onSetProductInChart(i, Number(e.target.value), true)}
                                        />

                                        <IconButton
                                            rounded={'none'}
                                            bg="black"
                                            size={'sm'}
                                            borderRightRadius={'8px'}
                                            aria-label="Search database"
                                            onClick={() => onSetProductInChart(i, 1, false)}
                                            icon={<AddIcon fontSize={'10px'} />}
                                        />
                                    </HStack>
                                ),
                            },
                            {
                                header: 'Total',
                                width: '250px',
                                render: (v) => {
                                    const find = state.productCheckout?.find((i) => i.id === v.productId)
                                    const sum = find?.finalPrice_ || 0
                                    // if (find) {
                                    //     sum = find.totalPrice - Number(find?.additional || 0)
                                    // }

                                    return (
                                        <Box w={'100px'}>
                                            {isLoadingPrice && v.productId === selectIdProduct ? (
                                                <Skeleton height="15px" w={'100px'} />
                                            ) : (
                                                <Text fontWeight={'semibold'}>{Shared.formatRupiah(String(sum))}</Text>
                                            )}
                                        </Box>
                                    )
                                },
                            },
                        ]}
                    />
                    <Box w={'fit-content'} mt={'12px'} pl={'-10px'}>
                        <PagingButton
                            page={Number(querys.page)}
                            nextPage={() => onSetPage(Number(querys.page) + 1)}
                            prevPage={() => onSetPage(Number(querys.page) - 1)}
                            disableNext={data?.next === null}
                        />
                    </Box>
                </Box>
            )}
        </Box>
    )
}

const PaymentMethod: React.FC<SummaryProps> = (props) => {
    const onChangePayment = (e: string) => {
        props.setValue('paymentMethod', Number(e))
    }
    const def = `${props.getValues('paymentMethod')}` || '1'
    const { state } = React.useContext(AppContext)

    return (
        <Box>
            <Text fontWeight={'semibold'}>Pembayaran</Text>
            <Divider my={3} />
            <RadioGroup defaultValue={def} fontSize={'15px'} onChange={onChangePayment}>
                <VStack align={'start'} spacing={5} direction="row">
                    <Radio colorScheme="red" value="2">
                        <Text fontWeight={'semibold'}>BANK TRANSFER</Text>
                    </Radio>
                    <Radio colorScheme="red" value="0">
                        <Text fontWeight={'semibold'}>COD</Text>
                    </Radio>
                    {Number(state.totalPrice) > 500000 && (
                        <Radio colorScheme="red" value="1">
                            <Text fontWeight={'semibold'}>TOP</Text>
                        </Radio>
                    )}
                </VStack>
            </RadioGroup>
        </Box>
    )
}

const RenderSummary: React.FC<SummaryProps> = (props) => {
    const inputRef = React.useRef<HTMLInputElement>(null)
    const setDisabelNext = useStoreSteps((v) => v.setDisabelNext)
    const { onPay, register } = props
    const { state } = React.useContext(AppContext)
    const codeSearchs = codeSearch()
    const { onSelectFile: onSelectFilePdf, selectedFile: selectedFilePdf } = usePickImage()

    React.useEffect(() => {
        if (selectedFilePdf) {
            props.setValue('pdfFile', selectedFilePdf)
        }
    }, [selectedFilePdf])

    React.useEffect(() => {
        setDisabelNext(true)
    }, [state.totalPrice, state.productCheckout])

    const handleClick = () => {
        inputRef.current?.click()
    }

    const setDate = () => {
        const today = new Date()
        const minDate = new Date(today.getTime() + 24 * 60 * 60 * 1000)
        const maxDate = new Date(today.getTime() + 30 * 24 * 60 * 60 * 1000)

        return {
            min: minDate.toISOString().substring(0, 10),
            max: maxDate.toISOString().substring(0, 10),
        }
    }

    if (!state.customers) return <LoadingForm />

    return (
        <Box pt={4} fontSize={'sm'}>
            <SimpleGrid columns={2} gap={4}>
                <Box>
                    <Text fontWeight={'semibold'}>Alamat Pengantaran</Text>
                    <Divider my={3} />
                    <Box experimental_spaceY={1}>
                        <Text fontWeight={'semibold'}>{state.customers.name} (PIC)</Text>
                        <Text>{state.customers.phone}</Text>
                        <Box>
                            <Text color={'gray.500'}>{state.addressShipp?.name}</Text>
                        </Box>
                    </Box>
                    <Divider my={3} />

                    <Text fontWeight={'semibold'}>Produk</Text>
                    <Divider my={3} />

                    <Box pt={1} experimental_spaceY={4} minH={'16vw'} maxH={'16vw'} overflow={'auto'}>
                        {/*    const priceDisc = v.discount + Number(v.additional || 0) */}
                        {state.productCheckout?.map((i, k) => {
                            const priceDisc = i.discount + Number(i.additional || 0)
                            const find = state.productCheckout?.find((v) => v.id === i.id)
                            const sum = find?.finalPrice_ || 0
                            return (
                                <HStack key={k} spacing={3}>
                                    <Image src={i.imageUrl} alt={i.name} rounded={'lg'} w={'70px'} h={'70px'} objectFit={'cover'} />
                                    <HStack justifyContent={'space-between'} w="full">
                                        <Box experimental_spaceY={1}>
                                            <Text>{i.name}</Text>
                                            <Text fontSize={'sm'}>{i.size}</Text>
                                            <Text fontSize={'sm'}>{i.categoryName}</Text>
                                        </Box>
                                        <Box>
                                            {priceDisc > 0 ? (
                                                <Box textAlign={'right'}>
                                                    <Text as="s"> {Shared.formatRupiah(`${i.unitPrice * i.qty}`)}</Text>
                                                    <Text fontWeight={'semibold'}>{Shared.formatRupiah(`${sum}`)}</Text>
                                                </Box>
                                            ) : (
                                                <Text textAlign={'right'} fontWeight={'semibold'}>
                                                    {Shared.formatRupiah(`${i.totalPrice}`)}
                                                </Text>
                                            )}
                                            <Text display={'flex'} color="gray" fontSize={'sm'} as={'span'} experimental_spaceX={2}>
                                                x
                                                <Text fontWeight={'semibold'} color="black">
                                                    {i.qty}
                                                </Text>
                                            </Text>
                                        </Box>
                                    </HStack>
                                </HStack>
                            )
                        })}
                    </Box>
                    <Divider my={3} />
                    <Box experimental_spaceY={3}>
                        <HStack justifyContent={'space-between'}>
                            <Text fontWeight={'semibold'}>Total Belanja</Text>

                            <Text fontWeight={'semibold'}>{Shared.formatRupiah(`${state.totalPrice}`)}</Text>
                        </HStack>

                        <HStack justifyContent={'space-between'}>
                            <Text fontWeight={'semibold'}>Total Ongkos Kirim</Text>
                            <Text fontWeight={'semibold'}>{Shared.formatRupiah(`${state.ongkir}`)}</Text>
                        </HStack>
                        <HStack justifyContent={'space-between'}>
                            <Text fontWeight={'semibold'}>Total Pembayaran</Text>

                            <Text fontWeight={'semibold'}>{Shared.formatRupiah(`${state.totalPrice}`)}</Text>
                        </HStack>
                    </Box>
                </Box>
                <Box>
                    <PaymentMethod {...props} />
                    <Divider my={3} />

                    <Box>
                        <Buttons label="Unggah PO" onClick={handleClick} />
                        <Text>{selectedFilePdf && selectedFilePdf?.name}</Text>
                        <input
                            ref={inputRef}
                            type="file"
                            accept="application/pdf"
                            style={{ display: 'none' }}
                            multiple={false}
                            onChange={(e) => {
                                onSelectFilePdf(e.target)
                            }}
                        />
                    </Box>
                    <Divider my={3} />

                    <HStack>
                        <FormSelects
                            async
                            loadOptions={codeSearchs}
                            label={'code_'}
                            control={props.control}
                            placeholder={'Pilih Kode'}
                            title={'Kode'}
                        />
                        <FormControls
                            type={'date'}
                            label={'deliveryAt'}
                            register={register}
                            minInput={setDate().min}
                            maxInput={setDate().max}
                            title={'Tanggal Pengantaran'}
                        />
                    </HStack>

                    <Divider my={3} />

                    <FormControlsTextArea label="customer.note" register={register} title={'Catatan'} />
                    <Buttons label="Proses" bg={'red.100'} w={'200px'} mt={3} onClick={onPay} isLoading={state.isLoadingCreate} />
                </Box>
            </SimpleGrid>
        </Box>
    )
}

const OrderCheckoutMain = () => {
    const navigate = useNavigate()
    const reOrder = reOrderState((i) => i.order)
    const reOrderCustomer = reOrderState((i) => i.customer)
    const reOrderProduct = reOrderState((i) => i.product)
    const toast = useToast()
    const admin = store.useStore((i) => i.admin)
    const { state, dispatch } = React.useContext(AppContext)
    const searchBranch = branchSearch()
    const [_, setIsCanExit] = React.useState(false)
    const { create } = orderService.useOrder()
    const { control, setValue, watch, getValues, formState, register } = useForm<IReqOrderReq>({
        defaultValues: { paymentMethod: EPaymentMethod.TRA },
    })
    const searhcCustomer = customerSearchByBranch(
        `${admin?.roles === Eroles.SALES_ADMIN ? getValues('branch_.value') : admin?.location?.id}`
    )

    const businessWatch = watch('business_.value')

    React.useEffect(() => {
        console.debug(watch('business_'))
        if (getValues('business_.value')) {
            const customers = JSON.parse(getValues('business_.value')) as Customers
            dispatch({
                customers: customers,
                address: customers.business.address,
            })
        }
    }, [watch('business_.value')])

    React.useEffect(() => {
        if (reOrder && reOrderCustomer && reOrderProduct) {
            dispatch({
                customers: reOrderCustomer,
                address: reOrderCustomer.business.address,
                productCheckout: reOrderProduct,
                addressShipp: {
                    name: reOrder.customer.addressName,
                    lngLat: reOrder.customer.addressLngLat,
                },
            })
        }
    }, [reOrder && reOrderCustomer && reOrderProduct])

    React.useEffect(() => {
        console.debug(watch('branch_'))
        if (admin && admin.roles === Eroles.BRANCH_SALES_ADMIN) {
            setValue('branch_.value', admin.location.id)
        }
    }, [getValues('branch_'), admin])

    const onCheckTeam = () => {
        if (!state.productCheckout) return
        const fProductFood = state.productCheckout.filter((v) => v.team === Eteam.FOOD)
        const fProductRetail = state.productCheckout.filter((v) => v.team === Eteam.RETAIL)
        const reduceRetail = fProductRetail.reduce((v, a) => v + a.totalPrice, 0)
        const reduceRetailQty = fProductRetail.reduce((v, a) => v + a.qty, 0)
        const reduceFood = fProductFood.reduce((v, a) => v + a.totalPrice, 0)
        const reduceFoodQty = fProductFood.reduce((v, a) => v + a.qty, 0)

        if (reduceRetail > reduceFood) {
            return Eteam.RETAIL
        }
        if (reduceFood > reduceRetail) {
            return Eteam.FOOD
        }
        if (reduceFood === reduceRetail) {
            if (reduceFoodQty > reduceRetailQty) {
                return Eteam.FOOD
            }
            if (reduceRetailQty > reduceFoodQty) {
                return Eteam.RETAIL
            }
        }
        return Eteam.FOOD
    }

    const onPayment = async () => {
        let code = ''
        let errorMessage = ''
        let userApprove: EmployeeApprover[] = []
        const md = new Date(getValues().deliveryAt).toISOString()
        const addLngLat = state.addressShipp?.lngLat || []
        const addressName = state.addressShipp?.name || ''
        const paymentMethod = Number(getValues().paymentMethod)
        if (!state.productCheckout) return

        try {
            dispatch({ isLoadingCreate: true })

            if (getValues().code_) {
                const codes = JSON.parse(`${getValues().code_?.value}`) as unknown as Code
                code = codes.id
            }

            if (paymentMethod === EPaymentMethod.TOP) {
                const findApprover = await getEmployeeApiInfo().findApproverTOP({
                    branchId: String(state.customers?.business.location.branchId),
                    regionId: String(state.customers?.business.location.regionId),
                    team: onCheckTeam() as Eteam,
                })

                if (findApprover) {
                    userApprove = findApprover
                }
            }

            const transaction = await findTransaction({ userId: `${state.customers?.id}` })

            const ReqData: CreateOrder = {
                branchId: String(state.customers?.business.location.branchId),
                branchName: String(state.customers?.business.location.branchName),
                code,
                pdfFile: getValues('pdfFile'),
                creator: {
                    id: String(admin?.id),
                    email: String(admin?.email),
                    name: String(admin?.name),
                    imageUrl: String(admin?.imageUrl),
                    phone: String(admin?.phone),
                    roles: Number(admin?.roles),
                    note: getValues('creator.note') || '-',
                    idOrder: '',
                },
                customer: {
                    id: String(state.customers?.id),
                    email: String(state.customers?.email),
                    imageUrl: String(state.customers?.imageUrl),
                    name: String(state.customers?.name),
                    note: `${getValues('customer.note')}`,
                    phone: String(state.customers?.phone),
                    picName: String(state.customers?.business.pic.name),
                    picPhone: String(state.customers?.business.pic.phone),
                    addressLngLat: addLngLat,
                    addressName: addressName,
                },
                deliveryAt: md,
                deliveryPrice: Number(state.ongkir),
                deliveryType: CourierType.INTERNAL,
                paymentMethod,
                poFilePath: '',
                priceId: String(state.customers?.business.priceList.id),
                priceName: String(state.customers?.business.priceList.name),
                product: state.productCheckout.map((v) => {
                    const priceDisc = v.discount + Number(v.additional || 0)
                    return {
                        ...v,
                        discount: priceDisc,
                        totalPrice: Number(v.finalPrice_),
                    }
                }),
                regionId: String(state.customers?.business.location.regionId),
                regionName: String(state.customers?.business.location.regionName),
                cancel: null,
                creditLimit: state.customers?.business.credit.limit || 0,
                creditUsed: state.customers?.business.credit.used || 0,
                productPrice: Number(state.totalPrice),
                termInvoice: state.customers?.business.credit.termInvoice || 0,
                totalPrice: Number(state.totalPrice),
                transactionLastMonth: transaction?.transactionLastMonth || 0,
                transactionPerMonth: transaction?.transactionPerMonth || 0,
                userApprover: userApprove,
            }

            schemaCreateOrder.parse(ReqData)

            await create.mutateAsync(ReqData, {
                onSuccess: () => {
                    setIsCanExit(false)
                },
            })
        } catch (e) {
            const err = e as Error
            errorMessage = err.message
            if (err instanceof ZodError) {
                // const errs = err.issues[0].path + ' ' + err.issues[0].message
                errorMessage = 'Cek kembali data yang anda masukan'
            }
            toast({
                status: 'error',
                description: errorMessage,
            })
        } finally {
            navigate({ pathname: '/order' })
            dispatch({ isLoadingCreate: false })
        }
    }

    const setHeight = React.useMemo(() => {
        if (window.screen.availWidth >= 1920) {
            return '90vh'
        }
        if (window.screen.availWidth >= 1535) {
            return '87vh'
        }
        if (window.screen.availWidth >= 1440) {
            return '85vh'
        }
        if (window.screen.availWidth >= 1366) {
            return '85vh'
        }

        return '100%'
    }, [window.screen.availWidth])

    return (
        <Wrap>
            {/* <ReactRouterPrompt when={isCanExit}>
                {({ isActive, onConfirm, onCancel }: { isActive: boolean; onConfirm: () => void; onCancel: () => void }) => (
                    <Modals isOpen={isActive} setOpen={onCancel} title="Peringatan">
                        <Box>
                            <Text fontWeight={'semibold'} fontSize={'xl'}>
                                Yakin ingin pindah halaman ?
                            </Text>
                            <ButtonForm
                                isLoading={false}
                                label="Ya"
                                onClick={onConfirm}
                                onClose={onCancel}
                                mt="10px"
                                labelClose="Kembali"
                            />
                        </Box>
                    </Modals>
                )}
            </ReactRouterPrompt> */}
            <Box bg="white" shadow={'md'} p={5} rounded={'lg'} minH={setHeight} maxH={setHeight} overflow={'auto'}>
                <Text fontWeight={'bold'} fontSize={'xl'} mb={2}>
                    Buat Pesanan
                </Text>
                <Divider />
                <>
                    <Box pt={2}>
                        <LoadingCheckout isLoading={create.isLoading} />
                        <StepsTimeLine
                            content={[
                                {
                                    label: 'Pilih Pelanggan',
                                    content: (
                                        <Box>
                                            <Divider my={2} />
                                            <Box>
                                                <HStack w={'full'}>
                                                    {admin?.roles === Eroles.SALES_ADMIN && (
                                                        <>
                                                            <FormSelects
                                                                async
                                                                loadOptions={searchBranch}
                                                                label="branch_"
                                                                title={'Cabang'}
                                                                placeholder="Pilih Cabang"
                                                                control={control}
                                                            />
                                                            {getValues('branch_') ? (
                                                                <FormSelects
                                                                    async={true}
                                                                    loadOptions={searhcCustomer}
                                                                    label="business_"
                                                                    title={'Pelanggan'}
                                                                    placeholder="Pilih Pelanggan"
                                                                    control={control}
                                                                    defaultOptions={false}
                                                                />
                                                            ) : null}
                                                        </>
                                                    )}
                                                    {admin?.roles === Eroles.BRANCH_SALES_ADMIN && (
                                                        <FormSelects
                                                            async
                                                            loadOptions={searhcCustomer}
                                                            label="business_"
                                                            title={'Pelanggan'}
                                                            placeholder="Pilih Pelanggan"
                                                            control={control}
                                                            defaultOptions={false}
                                                        />
                                                    )}
                                                </HStack>
                                                {businessWatch ? <RenderBusiness /> : null}
                                            </Box>
                                        </Box>
                                    ),
                                },
                                {
                                    label: 'Pilih Alamat Pengantaran',
                                    content: (
                                        <ShippingAddress
                                            setValue={setValue}
                                            control={control}
                                            formState={formState}
                                            getValues={getValues}
                                        />
                                    ),
                                },
                                {
                                    label: 'Pilih Produk',
                                    content: <RenderProduct />,
                                },
                                {
                                    label: 'Ringkasan',
                                    content: (
                                        <>
                                            {businessWatch || (reOrder && reOrderCustomer && reOrderProduct) ? (
                                                <RenderSummary
                                                    control={control}
                                                    setValue={setValue}
                                                    register={register}
                                                    getValues={getValues}
                                                    onPay={onPayment}
                                                />
                                            ) : null}
                                        </>
                                    ),
                                },
                            ].filter((v) => {
                                if (reOrder && reOrderCustomer && reOrderProduct) {
                                    return v.label !== 'Pilih Pelanggan'
                                }
                                return v
                            })}
                        />
                    </Box>
                </>
            </Box>
        </Wrap>
    )
}

export const OrderCreatePages: React.FC = () => {
    return (
        <Providers>
            <OrderCheckoutMain />
        </Providers>
    )
}
