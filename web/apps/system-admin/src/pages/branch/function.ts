import { SelectsTypes, getRegionApiInfo, getProdcutApiInfo, getPriceListApiInfo, ProductTypes } from 'apis'
import { ProductImportPrice } from './import-price'
import { ProductImport } from './import-qty'

export const SearchsRegion = () => {
    const s = (e: string): Promise<SelectsTypes[]> => {
        return new Promise<SelectsTypes[]>((resolve) => {
            const transform: SelectsTypes[] = []

            getRegionApiInfo()
                .find({
                    limit: 10,
                    page: 1,
                    search: e,
                })
                .then((res) => {
                    res.items.forEach((v) => {
                        transform.push({
                            value: JSON.stringify(v),
                            label: v.name,
                        })
                    })
                })

            resolve([...transform])
        })
    }

    return s
}

export const getProductImportQty = async (
    p: string,
    setData: (v: ProductImport[]) => void,
    setLoading: (v: boolean) => void,
    setError: (v: string) => void
) => {
    try {
        const dataTransform: ProductImport[] = []
        const response = await getProdcutApiInfo().findImportQty(p)
        response.forEach((i) => {
            dataTransform.push({
                ...i,
                isCheck: false,
                qty: 0,
                nQty: 0,
            })
        })
        setData(dataTransform)
    } catch (e) {
        const err = e as Error
        setError(err.message)
        console.log('error', e)
    } finally {
        setLoading(false)
    }
}

export const getProductBranchById = async (req: {
    productId: string
    branchId: string
    warehouseId: string
    setLoading: (v: boolean) => void
    setError: (v: string) => void
    setQty: React.Dispatch<
        React.SetStateAction<{
            qty: number
            productId: string
        }>
    >
}) => {
    let qty = 0
    try {
        req.setLoading(true)
        const response = await getProdcutApiInfo().findProductBranchById(`${req.branchId}-${req.productId}`)
        const find = response.warehouse.find((i) => i.id === req.warehouseId)
        if (find) {
            qty = find.qty
        }
        req.setQty((v) => {
            return {
                ...v,
                productId: find?.id || '',
                qty,
            }
        })
    } catch (e) {
        //
    } finally {
        req.setLoading(false)
    }
}

export const getProductImportPrice = async (
    id: string,
    setData: (v: ProductImportPrice[]) => void,
    setLoading: (v: boolean) => void,
    setError: (v: string) => void
) => {
    try {
        const dataTransform: ProductImportPrice[] = []
        const response = await getProdcutApiInfo().findImportPrice(id)
        response.forEach((i) => {
            if (i.branchId) {
                dataTransform.push({
                    ...i,
                    isCheck: false,
                })
            }
        })
        setData(dataTransform)
    } catch (e) {
        const err = e as Error
        setError(err.message)
        console.log('error', e)
    } finally {
        setLoading(false)
    }
}

export const getPriceListDefault = async (req: {
    productId: string
    setPriceList: (v: ProductTypes.PriceList[]) => void
    setLoading: (v: boolean) => void
}) => {
    const { productId, setLoading, setPriceList } = req
    setLoading(true)
    const priceList = await getPriceListApiInfo().find()
    let checkExist: ProductTypes.Product | null = null
    getProdcutApiInfo()
        .findProductBranchById(productId)
        .then((product) => {
            checkExist = product
            const transFilterPrice: ProductTypes.PriceList[] = priceList.map((pr) => {
                const priceList: ProductTypes.PriceList = {
                    discount: [],
                    id: pr.id,
                    name: pr.name,
                    price: 0,
                }
                const findPriceInProd = product.price.find((i) => i.id === priceList.id)
                if (findPriceInProd) {
                    // console.log('1', findPriceInProd)
                    priceList.price = findPriceInProd.price
                    priceList.discount = findPriceInProd.discount
                    priceList.id = findPriceInProd.id
                }
                return priceList
            })

            setPriceList([...transFilterPrice])
        })
        .finally(() => {
            if (!checkExist) {
                setPriceList(
                    priceList.map((v) => ({
                        price: 0,
                        id: v.id,
                        createdAt: v.createdAt,
                        updatedAt: v.updatedAt,
                        name: v.name,
                        discount: [],
                    }))
                )
            }

            setLoading(false)
        })
}
