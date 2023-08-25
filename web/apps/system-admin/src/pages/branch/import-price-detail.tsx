import { usePriceStore } from './import-price'
import {
    Avatar,
    Box,
    Divider,
    Drawer,
    DrawerBody,
    DrawerCloseButton,
    DrawerContent,
    DrawerHeader,
    HStack,
    IconButton,
    Input,
    SimpleGrid,
    Spinner,
    Text,
    VStack,
} from '@chakra-ui/react'
import { NumericFormat } from 'react-number-format'
import { CloseIcon } from '@chakra-ui/icons'
import React from 'react'
import { ProductTypes } from 'apis'
import { getPriceListDefault } from './function'
import { ButtonTooltip, Buttons, Icons, Modals, Tables, Types, useToast } from 'ui'

interface IPrice {
    productId: string
    price: ProductTypes.PriceList[]
}

const DetailPriceStrata: React.FC<{ setOpen: (v: boolean) => void; isOpen: boolean }> = ({ setOpen, isOpen }) => {
    const toast = useToast()

    const product = usePriceStore((v) => v.product)
    const setProduct = usePriceStore((v) => v.setProduct)
    const selectedPriceList = usePriceStore((v) => v.selectedPriceList)
    const [loading, setLoading] = React.useState(true)
    const [priceList, setPriceList] = React.useState<ProductTypes.PriceList[]>([])
    const removeSelectedPriceList = usePriceStore((v) => v.removeSelectedPriceList)
    const setSelectedPriceList = usePriceStore((v) => v.setSelectedPriceList)

    const [isOpenDiscount, setIsOpenDiscount] = React.useState(false)

    React.useEffect(() => {
        const datLocal = localStorage.getItem('priceList')
        if (datLocal) {
            const datPrice = JSON.parse(String(datLocal)) as IPrice[]
            const f = datPrice.find((v) => v.productId === product?.id)
            if (f) {
                setPriceList(f.price)
            } else {
                getPriceListDefault({ productId: `${product?.id}`, setLoading, setPriceList })
            }
            setLoading(false)
        } else {
            getPriceListDefault({ productId: `${product?.id}`, setLoading, setPriceList })
        }
    }, [loading])

    React.useEffect(() => {
        const datLocal = localStorage.getItem('priceList')
        let datPrice: IPrice[] = []
        if (datLocal) {
            datPrice = JSON.parse(String(datLocal)) as IPrice[]
        }
        if (priceList.length) {
            if (!product) return
            localStorage.setItem(
                'priceList',
                JSON.stringify([
                    ...datPrice.filter((v) => v.productId !== product.id),
                    {
                        productId: product.id,
                        price: priceList,
                    },
                ])
            )
        }
    }, [priceList])

    const onSaveToProduct = () => {
        if (!product) return
        setProduct({
            ...product,
            isCheck: true,
            price: priceList,
        })
        setOpen(false)
        toast({
            status: 'success',
            position: 'bottom-right',
            description: 'Berhasil memperbarui data',
        })
    }

    const onClose = () => {
        removeSelectedPriceList()
        onSaveToProduct()
    }

    const onCreateNewDiscount = (req: { priceId: string; type: 'new' | 'add' }) => {
        const mPa = priceList.map((p) => {
            if (p.id === req.priceId) {
                if (req.type === 'new') {
                    if (!p.discount.length) {
                        p.discount = [
                            {
                                discount: 0,
                                expiredAt: '',
                                max: 0,
                                min: 0,
                                startAt: '',
                            },
                        ]
                    } else {
                        p.discount = [...p.discount]
                    }
                }

                if (req.type === 'add') {
                    p.discount = [
                        ...p.discount,
                        {
                            discount: 0,
                            expiredAt: '',
                            max: 0,
                            min: 0,
                            startAt: '',
                        },
                    ]
                }
            }
            return p
        })
        setPriceList(mPa)
    }

    const onSetPrice = (req: { price: number; idx: number; priceId: string }) => {
        const discount = priceList.map((pri) => {
            if (pri.id === selectedPriceList?.id) {
                pri.discount[req.idx].discount = req.price
            }
            return pri
        })

        setPriceList(discount)
    }

    const onSetDate = (req: { startAt?: string; expiredAt?: string; priceId: string; idx: number }) => {
        const discount = priceList.map((pri) => {
            if (pri.id === selectedPriceList?.id) {
                if (req.startAt) {
                    pri.discount[req.idx].startAt = req.startAt
                }
                if (req.expiredAt) {
                    pri.discount[req.idx].expiredAt = req.expiredAt
                }
            }
            return pri
        })

        setPriceList(discount)
    }

    const onSetMaxMin = (req: { type: 'max' | 'min'; idx: number; priceId: string; value: number }) => {
        const setMax = () => {
            if (req.type === 'max' && req.value === 0) {
                return null
            }
            return req.value
        }

        const discount = priceList.map((pri) => {
            if (pri.id === selectedPriceList?.id) {
                if (req.type === 'max') {
                    pri.discount[req.idx].max = setMax()
                } else {
                    pri.discount[req.idx].min = req.value
                }
            }
            return pri
        })

        setPriceList(discount)
    }

    const onSetPrices = (req: { price: number; priceId: string }) => {
        const discount = priceList.map((pri) => {
            if (pri.id === req.priceId) {
                pri.price = req.price
                return pri
            }
            return pri
        })

        setPriceList(discount)
    }

    const setRemoveDiscount = (req: { idx: number; priceId: string }) => {
        const discount = priceList.map((pri) => {
            if (pri.id === req.priceId) {
                pri.discount = pri.discount.filter((_, idx) => idx !== req.idx)
            }
            return pri
        })
        setPriceList(discount)
    }

    const setRemoveAllDiscount = (req: { priceId: string }) => {
        const discount = priceList.map((pri) => {
            if (pri.id === req.priceId) {
                pri.discount = []
            }
            return pri
        })
        setPriceList(discount)
        toast({
            status: 'success',
            position: 'bottom-right',
            description: 'Berhasil hapus strata',
        })
    }

    const setDetaultDate = (d: string) => {
        const date = new Date(d)
        const year = date.getFullYear()
        const month = ('0' + (date.getMonth() + 1)).slice(-2)
        const day = ('0' + date.getDate()).slice(-2)
        const formattedDate = year + '-' + month + '-' + day
        return formattedDate
    }

    const column: Types.Columns<ProductTypes.PriceList>[] = [
        {
            header: 'Nama',
            render: (item) => item.name,
        },
        {
            header: 'Harga',
            render: (vPrice) => {
                return (
                    <NumericFormat
                        customInput={Input}
                        placeholder={'Ketik Harga'}
                        thousandSeparator="."
                        decimalSeparator=","
                        prefix="Rp. "
                        value={vPrice.price}
                        onValueChange={(e) => {
                            onSetPrices({ price: Number(e.floatValue), priceId: vPrice.id })
                        }}
                    />
                )
            },
            width: '200px',
        },
        {
            header: 'Jumlah Strata',
            render: (item) => item.discount.length,
        },
        {
            header: 'Strata',
            width: '10px ',
            render: (vPrice) => (
                <HStack>
                    <ButtonTooltip
                        icon={<Icons.AddIcons color={'gray'} />}
                        aria-label="add-strata"
                        label={'Tambah Strata'}
                        onClick={() => {
                            setIsOpenDiscount(true)
                            onCreateNewDiscount({ priceId: vPrice.id, type: 'new' })
                            setSelectedPriceList(vPrice, true)
                        }}
                    />
                    <ButtonTooltip
                        icon={<Icons.TrashIcons color={'gray'} />}
                        aria-label="add-strata"
                        label={'Hapus Strata'}
                        onClick={() => {
                            setRemoveAllDiscount({ priceId: vPrice.id })
                        }}
                    />
                </HStack>
            ),
        },
    ]

    return (
        <Modals isOpen={isOpen} setOpen={onClose} title="Strata" size="6xl" motion="slideInRight" backdropFilter={''} h={'600px'}>
            <HStack>
                <Avatar boxSize={'100px'} rounded={'full'} src={product?.imageUrl} />
                <VStack align={'stretch'}>
                    <Text fontWeight={'bold'}>{product?.name}</Text>
                    <Text fontSize={'sm'}>{product?.category.name}</Text>
                </VStack>
            </HStack>
            <Box minH={'430px'} maxH={'430px'} overflow={'auto'} px={3}>
                {loading && <Spinner />}
                {!loading && (
                    <VStack align={'stretch'} spacing={3}>
                        {/* PRODUCT */}

                        {/* LIST PIRCE LIST */}
                        <Box>
                            <Tables columns={column} isLoading={false} pageH={'100%'} data={priceList} />
                        </Box>

                        {isOpenDiscount && (
                            <Drawer isOpen={isOpenDiscount} placement="bottom" onClose={() => setIsOpenDiscount(false)}>
                                <DrawerContent>
                                    <DrawerCloseButton />
                                    <DrawerHeader>{selectedPriceList?.name}</DrawerHeader>
                                    <DrawerBody pb={'10px'}>
                                        {priceList.map((price) => {
                                            if (selectedPriceList?.id === price.id) {
                                                return (
                                                    <>
                                                        <Buttons
                                                            label="Tambah Strata"
                                                            onClick={() => {
                                                                onCreateNewDiscount({ priceId: price.id, type: 'add' })
                                                            }}
                                                        />

                                                        <Box minH={'250px'} maxH={'250px'} overflow={'auto'} px={'10px'}>
                                                            {price.discount.map((i, idx) => (
                                                                <>
                                                                    <>
                                                                        <HStack justify={'space-between'} w={'full'} mt={'10px'}>
                                                                            <IconButton
                                                                                aria-label=""
                                                                                icon={
                                                                                    <CloseIcon
                                                                                        width={'10px'}
                                                                                        height={'10px'}
                                                                                        color={'black'}
                                                                                    />
                                                                                }
                                                                                onClick={() => {
                                                                                    setRemoveDiscount({ idx, priceId: price.id })
                                                                                }}
                                                                                size={'sm'}
                                                                            />
                                                                        </HStack>
                                                                        <Divider my={2} />
                                                                        <SimpleGrid columns={5} gap={3}>
                                                                            <Box fontWeight={500}>
                                                                                <Text fontSize={'sm'}>Minimal</Text>
                                                                                <NumericFormat
                                                                                    value={i.min}
                                                                                    customInput={Input}
                                                                                    placeholder={'Ketik Jumlah Pembelian'}
                                                                                    onValueChange={(target) => {
                                                                                        onSetMaxMin({
                                                                                            type: 'min',
                                                                                            idx,
                                                                                            value: Number(target.value),
                                                                                            priceId: price.id,
                                                                                        })
                                                                                    }}
                                                                                />
                                                                            </Box>

                                                                            <Box fontWeight={500}>
                                                                                <Text fontSize={'sm'}>Maksimal</Text>
                                                                                <NumericFormat
                                                                                    value={i.max}
                                                                                    customInput={Input}
                                                                                    placeholder={'Ketik Jumlah Pembelian'}
                                                                                    onValueChange={(target) => {
                                                                                        onSetMaxMin({
                                                                                            type: 'max',
                                                                                            idx,
                                                                                            value: Number(target.value),
                                                                                            priceId: price.id,
                                                                                        })
                                                                                    }}
                                                                                />
                                                                            </Box>

                                                                            <Box fontWeight={500}>
                                                                                <Text fontSize={'sm'}>Diskon</Text>
                                                                                <NumericFormat
                                                                                    value={i.discount}
                                                                                    customInput={Input}
                                                                                    placeholder={'Ketik Diskon'}
                                                                                    thousandSeparator="."
                                                                                    decimalSeparator=","
                                                                                    prefix="Rp. "
                                                                                    onValueChange={(target) => {
                                                                                        const prices = Number(target.value)
                                                                                        onSetPrice({
                                                                                            price: prices,
                                                                                            idx,
                                                                                            priceId: price.id,
                                                                                        })
                                                                                    }}
                                                                                />
                                                                            </Box>

                                                                            <Box w="full">
                                                                                <Text fontSize={'sm'}>Mulai</Text>
                                                                                <Input
                                                                                    type="date"
                                                                                    placeholder="Pilih tanggal mulai"
                                                                                    defaultValue={setDetaultDate(i.startAt)}
                                                                                    onChange={(e) => {
                                                                                        const date = new Date(e.target.value).toISOString()
                                                                                        onSetDate({
                                                                                            idx,
                                                                                            startAt: date,
                                                                                            priceId: price.id,
                                                                                        })
                                                                                    }}
                                                                                />
                                                                            </Box>

                                                                            <Box w="full">
                                                                                <Text fontSize={'sm'}>Selesai</Text>
                                                                                <Input
                                                                                    type="date"
                                                                                    placeholder="Pilih tanggal selesai"
                                                                                    defaultValue={setDetaultDate(i.expiredAt)}
                                                                                    onChange={(e) => {
                                                                                        const date = new Date(e.target.value).toISOString()
                                                                                        onSetDate({
                                                                                            idx,
                                                                                            expiredAt: date,
                                                                                            priceId: price.id,
                                                                                        })
                                                                                    }}
                                                                                />
                                                                            </Box>
                                                                        </SimpleGrid>
                                                                    </>
                                                                </>
                                                            ))}
                                                        </Box>
                                                    </>
                                                )
                                            }
                                            return null
                                        })}
                                    </DrawerBody>
                                </DrawerContent>
                            </Drawer>
                        )}
                    </VStack>
                )}
            </Box>
        </Modals>
    )
}

export default DetailPriceStrata
