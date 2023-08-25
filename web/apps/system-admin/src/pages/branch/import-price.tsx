import React from 'react'
import { ButtonForm, Buttons, ButtonTooltip, entity, Icons, Modals, PText, Root, StackAvatar, Tables, Types, useToast } from 'ui'
import { z, ZodError } from 'zod'
import { Box, Checkbox, Text, HStack } from '@chakra-ui/react'
import { getProdcutApiInfo, ProductTypes } from 'apis'
import { getProductImportPrice } from './function'
import create from 'zustand'
import { useParams } from 'react-router-dom'
import { dataListLocation } from '~/navigation'
import DetailPriceStrata from './import-price-detail'
import CardDetailBranch from '~/pages/tag/card-detail-branch'
import ReactRouterPrompt from 'react-router-prompt'
import { disclousureStore } from '~/store'

const validationDiscount = z.object({
    discount: z.number(),
    expiredAt: z.coerce.date(),
    max: z.number().nullable(),
    min: z.number().min(1),
    startAt: z.coerce.date(),
})

const validationPriceList = z.object({
    id: z.string(),
    name: z.string(),
    price: z.number().min(1),
    discount: z.array(validationDiscount).optional(),
})

const validationSchema = z.object({
    price: z.array(validationPriceList),
})

interface PropsModalAddStrata {
    isOpen: boolean
    setOpen: (v: boolean) => void
}

export interface ProductImportPrice extends ProductTypes.Product {
    isCheck: boolean
}

export interface Discount {
    min?: number
    max?: number | null
    discount?: number
    startAt?: string
    expiredAt?: string
}

interface IStrata {
    isOpenStrata: boolean
    setOpenStrata: () => void
    strata: ProductTypes.Discount[]
    priceListId: string
    setStrata: (req: { strata: ProductTypes.Discount[]; priceListId: string }) => void
}

interface PriceState extends IStrata {
    setDataProduct: (v: ProductImportPrice[]) => void
    dataProduct: ProductImportPrice[]
    product?: ProductImportPrice | undefined
    priceList: ProductTypes.PriceList[]
    selectedPriceList: ProductTypes.PriceList | undefined
    setSelectedPriceList: (v: ProductTypes.PriceList, isDetail?: boolean) => void
    removeSelectedPriceList: () => void
    setProduct: (v: ProductImportPrice) => void
    setProductOnDiscount: (v: ProductImportPrice) => void
    setPriceList: (v: ProductTypes.PriceList[]) => void
    setRemoveDiscount: (idx: number, priceId: string) => void
    setDiscount: (req: { idx: number; priceId: string; discount: ProductTypes.Discount }) => void
}

interface TriggerModal {
    isClose: boolean
    type: 'create' | '-'
    setIsClose: (v: boolean) => void
    setType: (v: 'create' | '-') => void
}

export const useTriggerModal = create<TriggerModal>((set) => ({
    isClose: false,
    type: '-',
    setIsClose: (v) => set({ isClose: v }),
    setType: (v) => set({ type: v }),
}))

export const usePriceStore = create<PriceState>()((set, get) => ({
    dataProduct: [],
    product: undefined,
    priceList: [],
    selectedPriceList: undefined,
    setDiscount: (req) => {
        const dataProduct = get().dataProduct
        const product = get().product
        set({
            dataProduct: [
                ...dataProduct.map((i) => {
                    if (i.id === product?.id) {
                        const findPrice = product.price.find((j) => j.id === req.priceId)
                        if (findPrice) {
                            const f = findPrice.discount.map((j, idxDiscount) => {
                                if (idxDiscount === req.idx) {
                                    return req.discount
                                }
                                return j
                            })
                            findPrice.discount = [...f]
                        }
                        return {
                            ...product,
                            price: [...product.price],
                        }
                    }
                    return i
                }),
            ],
        })
    },
    removeSelectedPriceList: () => {
        const selectedPriceList = get().selectedPriceList
        if (!selectedPriceList) return

        set({ selectedPriceList: undefined })
    },
    setRemoveDiscount: (idx, priceId) => {
        const dataProduct = get().dataProduct
        set({
            dataProduct: [
                ...dataProduct.map((i) => {
                    const idxPrice = i.price.findIndex((j) => j.id === priceId)
                    if (idxPrice !== -1) {
                        const discount = i.price[idxPrice].discount.filter((j, idxDiscount) => idxDiscount !== idx)
                        i.price[idxPrice].discount = [...discount]
                    }
                    return i
                }),
            ],
        })
    },
    setSelectedPriceList: (v) => {
        const product = get().product
        const dataProduct = get().dataProduct
        if (!product) return

        set({ selectedPriceList: v })
        set({
            dataProduct: [
                ...dataProduct.map((i) => {
                    if (i.id === product?.id) {
                        const findPrice = i.price.find((pr) => pr.id === v?.id)
                        if (findPrice) {
                            if (!findPrice.discount.length) {
                                findPrice.discount = [{ discount: 0, max: 0, min: 0, expiredAt: '', startAt: '' }]
                            } else {
                                findPrice.discount = [...findPrice.discount, ...v.discount]
                            }
                            return {
                                ...i,
                                price: [...i.price.filter((price) => price.id !== findPrice?.id), findPrice],
                            }
                        }
                    }

                    return i
                }),
            ],
        })
    },
    setProductOnDiscount: (v) => {
        const data = get().dataProduct
        const dMap = data.map((prod) => {
            if (v.id === prod.id) {
                return v
            }
            return prod
        })

        set({ dataProduct: dMap })
    },
    setDataProduct: (v) => set({ dataProduct: v }),
    setProduct: (v) => {
        const dataProcts = get().dataProduct
        // const setPriceList = get().setPriceList
        const nProd = dataProcts.map((i) => {
            if (i.id === v.id) {
                return v
            }
            return i
        })
        set({ product: v, dataProduct: nProd })
    },
    setPriceList: (v) => {
        // const product = get().product!
        // const dataProduct = get().dataProduct

        // const findProduct = dataProduct.find((i) => i.id === product?.id)!
        // const price = findProduct.price.map((i) => {
        //     const findPrice = v?.find((j) => j.id === i.id)
        //     if (findPrice) {
        //         return findPrice
        //     }
        //     return i
        // })

        set({ priceList: v })
    },
    setStrata: (v) => set({ strata: v.strata, priceListId: v.priceListId }),
    strata: [],
    isOpenStrata: false,
    setOpenStrata: () => {
        const open = get().isOpenStrata
        set({ isOpenStrata: !open })
    },
    priceListId: '',
}))

const Wrap: React.FC<{ children: React.ReactNode }> = ({ children }) => (
    <Root appName="System" items={dataListLocation} backUrl={'/branch'} activeNum={2}>
        {children}
    </Root>
)

const PriceImport: React.FC = () => {
    const toast = useToast()
    const params = useParams() as { id: string }
    const setPrompt = disclousureStore((v) => v.setPrompt)
    const isPrompt = disclousureStore((v) => v.isPrompt)
    const [errors, setErrors] = React.useState('')
    const [isRefetch, setRefetch] = React.useState(false)
    const { column, isOpen: isOpens, setOpen: setOpens } = columns()
    const [isLoading, setLoadScreen] = React.useState(true)
    const setDataProduct = usePriceStore((v) => v.setDataProduct)
    const [isLoadingImport, setLoadingImport] = React.useState(false)
    const dataProduct = usePriceStore((v) => v.dataProduct)

    React.useEffect(() => {
        getProductImportPrice(params.id, setDataProduct, setLoadScreen, setErrors)
    }, [isRefetch])

    React.useEffect(() => {
        dataProduct.forEach((v) => {
            if (v.isCheck) {
                setPrompt(true)
            }
        })
    }, [dataProduct])

    const checkProductStrataPrice = async () => {
        const filterProdCheck = dataProduct.filter((v) => v.isCheck)
        const res = await new Promise<ProductImportPrice[]>((resolve) => {
            const v = filterProdCheck.map((prod) => {
                const filPrice = prod.price.filter((pr) => pr.price > 0)
                filPrice.forEach((p) => {
                    p.discount.sort((a, b) => a.min - b.min)
                })

                const fPrice = filPrice.filter((item) => item.price !== 0)
                return {
                    ...prod,
                    price: fPrice,
                }
            })
            resolve(v)
        })

        return res
    }

    const onImport = async () => {
        const err: string[] = []
        try {
            setLoadingImport(true)
            const resCheck = await checkProductStrataPrice()
            const filteredDataProduct = resCheck.filter((product) => product.price.length > 0)

            const updatedDadta = filteredDataProduct.map((item) => ({
                ...item,
                price: item.price.map((price) => ({
                    ...price,
                    discount: price.discount.map((discount) => (discount.max === 0 ? { ...discount, max: null } : discount)),
                })),
            }))

            for await (const v of updatedDadta) {
                if (v.isCheck) {
                    await validationSchema.parseAsync(v)
                }
            }

            for await (const i of updatedDadta) {
                try {
                    await getProdcutApiInfo().createProductInBranch({
                        ...i,
                        productId: i.productId,
                        id: i.id,
                    })
                } catch (error) {
                    const e = error as Error
                    err.push(e.message)
                }
            }
            localStorage.removeItem('priceList')
            setPrompt(false)
            setRefetch(!isRefetch)
        } catch (e) {
            const error = e as Error
            let msg = error?.message
            err.push(msg)
            if (e instanceof ZodError) {
                console.log(e)
                // msg = `${e.errors[0].message} in ${e.errors[0].path.join('.')}`
                msg = 'Input tidak valid'
            }
            toast({
                position: 'bottom-right',
                description: `${msg}`,
            })
        } finally {
            setLoadingImport(false)

            if (err.length === 0) {
                toast({
                    position: 'bottom-right',
                    description: 'Berhasil Simpan Data',
                    status: 'success',
                })
            }

            if (err.length > 0) {
                toast({
                    position: 'bottom-right',
                    description: 'Input tidak valid',
                    status: 'info',
                })
            }
        }
    }

    return (
        <Wrap>
            <ReactRouterPrompt when={isPrompt}>
                {({ isActive, onConfirm, onCancel }: { isActive: boolean; onConfirm: () => void; onCancel: () => void }) => (
                    <Modals
                        isOpen={isActive}
                        setOpen={() => {
                            onCancel()
                        }}
                    >
                        <Box>
                            <Text fontWeight={'semibold'} fontSize={'xl'}>
                                Yakin ingin pindah halaman ?
                            </Text>
                            <Text>Sebelum pindah halaman, pastikan pembaruan data telah tersimpan</Text>
                            <ButtonForm
                                isLoading={false}
                                label="Ya"
                                onClick={() => {
                                    onConfirm()
                                    setDataProduct([])
                                }}
                                onClose={() => {
                                    onCancel()
                                }}
                                mt="10px"
                                labelClose="Kembali"
                            />
                        </Box>
                    </Modals>
                )}
            </ReactRouterPrompt>
            {errors ? (
                <PText label={errors} />
            ) : (
                <>
                    <CardDetailBranch type="price" />
                    <HStack>
                        <Buttons
                            isLoading={isLoadingImport}
                            label="Simpan"
                            width={'200px'}
                            leftIcon={<Icons.ImportIcons color={'white'} />}
                            onClick={onImport}
                        />
                    </HStack>
                    <Tables columns={column} isLoading={isLoading} data={!dataProduct ? [] : dataProduct} usePaging={true} />
                </>
            )}
            <ModalAddStrata isOpen={isOpens} setOpen={setOpens} />
        </Wrap>
    )
}

const ModalAddStrata: React.FC<PropsModalAddStrata> = ({ isOpen, setOpen }) => {
    if (!isOpen) return null

    return <DetailPriceStrata setOpen={setOpen} isOpen={isOpen} />
}

const columns = () => {
    const setDataProduct = usePriceStore((v) => v.setDataProduct)
    const dataProduct = usePriceStore((v) => v.dataProduct)
    const setProduct = usePriceStore((v) => v.setProduct)
    const [isOpen, setOpen] = React.useState(false)

    const checkAll = (value: boolean) => {
        const set = dataProduct.map((i) => ({
            ...i,
            isCheck: value,
        }))

        setDataProduct(set)
    }

    const onCheck = (req: { productId: string; v: boolean }) => {
        const set = dataProduct.map((i) => {
            if (i.id === req.productId) {
                return {
                    ...i,
                    isCheck: req.v,
                }
            }
            return i
        })
        setDataProduct(set)
    }

    const column: Types.Columns<ProductImportPrice>[] = [
        {
            header: (
                <Checkbox
                    defaultChecked={false}
                    onChange={(e) => {
                        checkAll(e.target.checked)
                    }}
                ></Checkbox>
            ),
            render: (v) => {
                return (
                    <Checkbox
                        isChecked={v.isCheck}
                        onChange={(e) => {
                            onCheck({ productId: v.id, v: e.target.checked })
                        }}
                    ></Checkbox>
                )
            },
            width: '50px',
        },
        {
            header: 'ID',
            render: (v) => <Text>{v.id}</Text>,
            width: '200px',
        },
        {
            header: 'Nama',
            render: (v) => <Text>{v.name}</Text>,
            width: '200px',
        },
        {
            header: 'Kategori',
            render: (v) => <Text>{v.category.name}</Text>,
            width: '200px',
        },
        {
            header: 'Ukuran',
            render: (v) => <Text>{v.size}</Text>,
            width: '200px',
        },
        {
            header: 'Brand',
            render: (v) => <StackAvatar imageUrl={v.brand.imageUrl} name={v.brand.name} />,
            width: '200px',
        },
        {
            header: 'Tim',
            render: (v) => <Text>{entity.team(String(v.category.team))}</Text>,
            width: '200px',
        },
        {
            header: 'Harga',
            render: (v) => (
                <ButtonTooltip
                    label={'Tambah Harga'}
                    icon={<Icons.AddIcons color={'gray'} />}
                    onClick={() => {
                        setOpen(true)
                        setProduct(v)
                    }}
                />
            ),
        },
    ]

    return { column, isOpen, setOpen }
}

export default PriceImport
