import { ReqPaging, ResPaging } from '../'
import queryString from 'query-string'
import { req } from '../../request'
import { uploadFile } from '../../storage'
import * as ProductTypes from './types'

export class CreateQty implements ProductTypes.CreateQty {
    branchId: string
    productId: string
    warehouseId: string
    warehouseName: string
    qty: number
    creator: ProductTypes.Creator

    constructor(i: ProductTypes.CreateQty) {
        this.branchId = i.branchId
        this.productId = i.productId
        this.warehouseId = i.warehouseId
        this.warehouseName = i.warehouseName
        this.qty = i.qty
        this.creator = i.creator
    }
}

interface ReqGetDiscount {
    priceList: ProductTypes.PriceList[]
    idPriceList: string
    qty: number
}

export class PriceProducts {
    constructor() { }

    getDiscount(r: ReqGetDiscount): number {
        let d = 0
        const priceList = r.idPriceList
        const findpriceList = r.priceList?.find((i) => i.id === priceList)
        const disco = findpriceList?.discount || null
        if (disco === null) {
            d = 0
        } else if (findpriceList) {
            disco.forEach((i) => {
                const expiredAt = new Date(i.expiredAt || '')
                const startAt = new Date(i.startAt || '')

                if (startAt < new Date() && expiredAt > new Date() && r.qty >= i.min) {
                    if (i.max === null) {
                        d = i.discount * r.qty
                    } else if (i.max !== null && r.qty > i.max) {
                        d = 0
                    } else if (i.max !== null && r.qty <= i.max) {
                        d = i.discount * r.qty
                    }
                }
            })
        }

        return d
    }

    getPriceOfProduct(r: ReqGetDiscount): number {
        let d = 0

        const find = r.priceList.find((item) => item.id === r.idPriceList)
        if (find) {
            d = find.price
        }
        return d
    }

    getStrataOfProduct(r: ReqGetDiscount): ProductTypes.PriceList | undefined {
        let d = undefined
        const find = r.priceList.find((item) => item.id === r.idPriceList)
        if (find) {
            d = find
        }
        return d
    }
}

export class ProductBranch implements ProductTypes.Product {
    id: string
    branchId: string
    productId: string
    category: ProductTypes.Category
    brand: ProductTypes.Brand
    salesId: string
    salesName: string
    name: string
    description: string
    size: string
    imageUrl: string
    point: number
    price: ProductTypes.PriceList[]
    warehouse: ProductTypes.Warehouse[]
    orderCount: number
    isVisible: boolean
    createdAt: string
    updatedAt: string

    constructor(data: ProductTypes.Product) {
        this.id = data.id
        this.branchId = data.branchId
        this.productId = data.productId
        this.category = data.category
        this.brand = data.brand
        this.name = data.name
        this.description = data.description
        this.size = data.size
        this.imageUrl = data.imageUrl
        this.point = data.point
        this.price = data.price
        this.warehouse = data.warehouse
        this.orderCount = data.orderCount
        this.isVisible = data.isVisible
        this.salesId = data.salesId
        this.salesName = data.salesName
        this.createdAt = data.createdAt
        this.updatedAt = data.updatedAt
    }

    getQtyByWarehouseId(
        warehouseId: string
    ): ProductTypes.WarehouseList | undefined {
        const warehouseItem = this.warehouse.find(
            (item) => item.id === warehouseId
        )
        return warehouseItem
    }
}

export class Api {
    private static instance: Api
    private constructor() { }
    public static getInstance(): Api {
        if (!Api.instance) {
            Api.instance = new Api()
        }
        return Api.instance
    }
    private pathCatalog = '/product-catalog/v1'
    private pathBranch = '/product-branch/v1'
    private pathHistory = '/product-history/v1'
    private pathSales = '/product-sales/v1'
    private errors: { [key: number]: string } = {
        400: 'input tidak valid',
        401: 'hak akses ditolak',
        404: 'product tidak ditemukan',
        403: 'forbidden',
        500: 'server sedang bermasalah, silahkan coba beberapa saat lagi',
    }

    /**
     * SECTION PRODCUT CATALOG
     * @returns
     */

    setUrlProduct(path: string, r: ProductTypes.ReqProductFind) {
        const q = queryString.stringify(
            {
                query: [r.branchId, r.brandId, r.categoryId, r.team, r.salesId],
                num: r.page,
                limit: r.limit,
                search: r.search,
                sort:
                    r.sort === ProductTypes.ESort['ORDER COUNT']
                        ? 1
                        : r.sort === ProductTypes.ESort['DISCOUT']
                            ? 2
                            : '',
            },
            {
                skipEmptyString: true,
                skipNull: true,
                arrayFormat: 'separator',
                arrayFormatSeparator: ',',
            }
        )
        return `${path}?${q}`
    }

    async find(r: ProductTypes.ReqProductFind) {
        const data = await req<ProductTypes.Product[]>({
            method: 'GET',
            path: this.setUrlProduct(this.pathCatalog, r),
            errors: this.errors,
        })
        return data
    }

    async findById(id: string) {
        const data = await req<ProductTypes.Product>({
            method: 'GET',
            path: `${this.pathCatalog}/${id}`,
            errors: this.errors,
        })
        return data
    }

    async create(r: ProductTypes.CreateProduct): Promise<ProductTypes.Product> {
        const reqM: Omit<ProductTypes.CreateProduct, 'id'> = {
            name: r.name,
            brand: {
                id: r.brand.id,
                imageUrl: r.brand.imageUrl,
                name: r.brand.name,
            },
            category: {
                id: r.category.id,
                name: r.category.name,
                team: r.category.team,
            },
            description: r.description,
            point: r.point,
            size: r.size,
        }

        const res = await req<ProductTypes.Product>({
            method: 'POST',
            path: `${this.pathCatalog}/${r.id}`,
            body: reqM,
            errors: this.errors,
        })
        if (r.image_) {
            await uploadFile({
                file: r.image_,
                path: `product/${res.id}/${Date.now()}`,
            })
        }

        return res
    }

    async delete(id: string): Promise<ProductTypes.Product> {
        const res = await req<ProductTypes.Product>({
            method: 'DELETE',
            path: `${this.pathCatalog}/${id}`,
            errors: this.errors,
        })

        return res
    }

    /**
     * SECTION PRODUCT IN BRANCH
     * @param r ReqFindProductInBranch
     * @returns
     */

    // pathProdInBranch(r: ProductTypes.ReqFindProductInBranch) {
    //     const filterQueryString = queryString.stringify(
    //         { ...r },
    //         { skipEmptyString: true, skipNull: true }
    //     )

    //     return `${this.pathBranch}/${r.branchId}?num=${r.page}&limit=${r.limit}&${filterQueryString}`
    // }

    async findProductBranch(r: ProductTypes.ReqProductFind) {
        const data = await req<ResPaging<ProductTypes.Product>>({
            method: 'GET',
            path: this.setUrlProduct(this.pathBranch, r),
            errors: this.errors,
        })
        return data
    }

    async findProductBranchById(
        branchId: string
    ): Promise<ProductTypes.Product> {
        const data = await req<ProductTypes.Product>({
            method: 'GET',
            path: `${this.pathBranch}/${branchId}`,
            errors: this.errors,
        })
        return data
    }

    async createProductInBranch(r: ProductTypes.CrateProductBranch) {
        const data = await req<ProductTypes.Product>({
            method: 'POST',
            path: `${this.pathBranch}/${r.id}`,
            body: r,
            errors: this.errors,
        })
        return data
    }

    async createProductPrice(
        r: ProductTypes.ProductPrice
    ): Promise<ProductTypes.Product> {
        const onData = [...r.price]

        const res = await req<ProductTypes.Product>({
            method: 'POST',
            path: `${this.pathBranch}/${r.branchId}/${r.productId}`,
            body: onData,
            errors: this.errors,
        })

        return res
    }

    async addQtyProduct(r: ProductTypes.CreateQty): Promise<void> {
        const onData: Omit<ProductTypes.CreateQty, 'branchId' | 'productId'> = {
            warehouseId: r.warehouseId,
            warehouseName: r.warehouseName,
            qty: Number(r.qty),
            creator: r.creator,
        }

        await req<void>({
            method: 'PUT',
            path: `${this.pathBranch}/${r.productId}`,
            body: onData,
            errors: this.errors,
        })
    }

    async transferQty(r: ProductTypes.CreateTransferQty): Promise<void> {
        const onData: Omit<
            ProductTypes.CreateTransferQty,
            'branchId' | 'productId'
        > = {
            fromWarehouseId: r.fromWarehouseId,
            fromWarehouseName: r.fromWarehouseName,
            toWarehouseId: r.toWarehouseId,
            toWarehouseName: r.toWarehouseName,
            qty: Number(r.qty),
            creator: r.creator,
        }

        await req<void>({
            method: 'PATCH',
            path: `${this.pathBranch}/${r.productId}`,
            body: onData,
            errors: this.errors,
        })
    }

    async updateVisibleProcutInBrancb(
        productId: string
    ): Promise<ProductTypes.Product> {
        const data = await req<ProductTypes.Product>({
            method: 'DELETE',
            path: `${this.pathBranch}/${productId}`,
            errors: this.errors,
        })
        return data
    }

    /**
     * SECTION PRODUCT HISTORY
     * @param r
     * @returns
     */

    pathHistorys(r: ProductTypes.ReqFindProductInBranch) {
        let path = `${this.pathHistory}?num=${r.page}&limit=${r.limit}`
        if (r.branchId) {
            path += `&branchId=${r.branchId}`
        }
        return path
    }

    async findProductHistory(
        r: Omit<ProductTypes.ReqFindProductInBranch, 'qType' | 'qvalue'>
    ): Promise<ResPaging<ProductTypes.HistoryQty>> {
        const data = await req<ResPaging<ProductTypes.HistoryQty>>({
            method: 'GET',
            path: this.pathHistorys(r),
            errors: this.errors,
        })
        return data
    }

    async findHistoryById(r: string) {
        const data = await req<ProductTypes.HistoryQty>({
            method: 'GET',
            path: `${this.pathHistory}/${r}`,
            errors: this.errors,
        })
        return data
    }

    async findSalesProductInBranch(branchId: string) {
        const data = await req<ProductTypes.ProductSales[]>({
            method: 'GET',
            path: `${this.pathSales}?branchId=${branchId}`,
            errors: this.errors,
        })
        return data
    }

    async updateSalesProduct(
        r: ProductTypes.UpdateSalesProduct
    ): Promise<ProductTypes.UpdateSalesProduct> {
        const data = await req<ProductTypes.UpdateSalesProduct>({
            method: 'PUT',
            path: `${this.pathSales}`,
            body: r,
            errors: this.errors,
        })
        return data
    }

    async findSalesProduct(branchId: string) {
        const data = await req<ProductTypes.SalesProduct[]>({
            method: 'GET',
            path: `${this.pathSales}?branchId=${branchId}`,
            errors: this.errors,
        })
        return data
    }

    async findImportPrice(branchId: string) {
        const data = await req<ProductTypes.Product[]>({
            method: 'GET',
            path: `${this.pathBranch}/${branchId}/find-import-price`,
            errors: this.errors,
        })
        return data
    }

    async findImportQty(branchId: string) {
        const data = await req<ProductTypes.Product[]>({
            method: 'GET',
            path: `${this.pathBranch}/${branchId}/find-import-qty`,
            errors: this.errors,
        })
        return data
    }
}
