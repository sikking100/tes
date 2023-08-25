import React from 'react'
import { Box, Input, Checkbox, Text } from '@chakra-ui/react'
import { store } from 'hooks'
import { ButtonForm, Buttons, Icons, Modals, PText, Root, StackAvatar, Tables, Types, entity, useToast } from 'ui'
import { ProductTypes, Warehouse, getProdcutApiInfo, getBranchApiInfo } from 'apis'
import { getProductImportQty } from './function'
import { dataListLocation } from '~/navigation'
import { useParams } from 'react-router-dom'
import create from 'zustand'
import CardDetailBranch from '~/pages/tag/card-detail-branch'
import ReactRouterPrompt from 'react-router-prompt'
import { disclousureStore } from '~/store'

export interface ProductImport extends ProductTypes.Product {
    isCheck: boolean
    qty: number
    nQty: number
}

interface IQtyImport {
    product: ProductImport[]
    setProduct: (product: ProductImport[]) => void
}

const useQtyImport = create<IQtyImport>((set) => ({
    product: [],
    setProduct: (product) => set({ product }),
}))

const Wrap: React.FC<{ children: React.ReactNode }> = ({ children }) => (
    <Root appName="System" items={dataListLocation} backUrl={'/branch'} activeNum={2}>
        {children}
    </Root>
)

const QtyImportPages = () => {
    const admin = store.useStore((i) => i.admin)
    const toast = useToast()
    const setPrompt = disclousureStore((v) => v.setPrompt)
    const isPrompt = disclousureStore((v) => v.isPrompt)
    const [isRefetch, setRefetch] = React.useState(false)
    const [loadScreen, setLoadScreen] = React.useState(true)
    const product = useQtyImport((v) => v.product)
    const setProduct = useQtyImport((v) => v.setProduct)
    const [errors, setErrors] = React.useState('')
    const [warehouse, setWarehouse] = React.useState<Warehouse>()
    const params = useParams() as { id: string }
    const [isLoadingImport, setLoadingImport] = React.useState(false)

    const { column } = columns(warehouse?.id ?? '')

    React.useEffect(() => {
        getProductImportQty(params.id, setProduct, setLoadScreen, setErrors)
        getBranchApiInfo()
            .getWarehouseByBranch(params.id)
            .then((res) => {
                res.forEach((i) => {
                    if (i.isDefault) {
                        setWarehouse(i)
                    }
                })
            })
    }, [isRefetch])

    React.useEffect(() => {
        product.forEach((v) => {
            if (v.isCheck) {
                setPrompt(true)
            }
        })
    }, [product])

    const onImport = async () => {
        setLoadingImport(true)
        const mData: ProductTypes.CreateQty = {
            branchId: params.id,
            qty: 0,
            productId: '',
            warehouseId: `${warehouse?.id}`,
            warehouseName: `${warehouse?.name}`,
            creator: {
                id: `${admin?.id}`,
                imageUrl: `${admin?.imageUrl}`,
                name: `${admin?.name}`,
                roles: Number(admin?.roles),
            },
        }
        const err: string[] = []

        for await (const i of product) {
            if (i.isCheck) {
                try {
                    await getProdcutApiInfo().addQtyProduct({
                        ...mData,
                        productId: i.id,
                        qty: Number(i.qty),
                    })
                } catch (error) {
                    const e = error as Error
                    err.push(e.message)
                }
            }
        }

        if (err.length === 0) {
            setPrompt(false)
            setRefetch(!isRefetch)
            setLoadingImport(false)
            toast({
                position: 'bottom-right',
                description: 'Berhasil Simpan Data',
                status: 'success',
            })
        }

        if (err.length > 0) {
            setLoadingImport(false)
            toast({
                position: 'bottom-right',
                description: `${err[0]}`,
                status: 'info',
            })
        }

        setLoadingImport(false)
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
                                    setProduct([])
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
                    <CardDetailBranch type="qty" />
                    <Buttons
                        isLoading={isLoadingImport}
                        label="Simpan"
                        width={'200px'}
                        leftIcon={<Icons.ImportIcons color={'white'} />}
                        onClick={onImport}
                    />

                    <Tables columns={column} isLoading={loadScreen} data={loadScreen ? [] : product} usePaging={true} />
                </>
            )}
        </Wrap>
    )
}

const columns = (warehouseId: string) => {
    // const cols = Columns.columnsProduct
    const product = useQtyImport((v) => v.product)
    const setProduct = useQtyImport((v) => v.setProduct)
    const [isOpen, setOpen] = React.useState(false)

    const onCheckAll = (e: React.ChangeEvent<HTMLInputElement>) => {
        const v = product.map((i) => {
            return {
                ...i,
                isCheck: e.target.checked,
            }
        })
        setProduct(v)
    }

    const onCheck = (req: { productId: string; v: boolean }) => {
        const set = product.map((i) => {
            if (i.id === req.productId) {
                return {
                    ...i,
                    isCheck: req.v,
                }
            }
            return i
        })
        setProduct(set)
    }

    const onChangeQty = (e: React.ChangeEvent<HTMLInputElement>, id: string) => {
        // const dataEmpty: ProductImport[] = product
        // const find = product.findIndex((v) => v.id === id)
        // dataEmpty[find].qty = Number(e.target.value)
        // dataEmpty[find].isCheck = true
        const mProduct = product.map((i) => {
            if (i.id === id) {
                i.qty = Number(e.target.value)
                i.isCheck = true
            }
            return i
        })
        setProduct(mProduct)
    }

    const column: Types.Columns<ProductImport>[] = [
        {
            header: (
                <Checkbox
                    defaultChecked={false}
                    onChange={(e) => {
                        onCheckAll(e)
                    }}
                ></Checkbox>
            ),
            render: (v) => (
                <Checkbox
                    isChecked={v.isCheck}
                    onChange={(e) => {
                        onCheck({
                            productId: v.id,
                            v: e.target.checked,
                        })
                    }}
                ></Checkbox>
            ),
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
            header: 'Stok Terkini',
            render: (v) => {
                const find = v.warehouse.find((v) => v.id === warehouseId)
                return <Text>{find ? find.qty : 0}</Text>
            },
            width: '200px',
        },
        {
            header: 'Stok',
            render: (v) => (
                <Input
                    placeholder="Ketik Stok"
                    type={'number'}
                    w="200px"
                    rounded={'md'}
                    size="sm"
                    onChange={(e) => {
                        onChangeQty(e, v.id)
                    }}
                />
            ),
            width: '200px',
        },
    ]

    return { column, isOpen, setOpen }
}

export default QtyImportPages
