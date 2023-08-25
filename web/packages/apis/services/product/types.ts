import { Eteam, ReqPaging } from '..'

export type CrateProductBranch = Omit<
    Product,
    'warehouse' | 'orderCount' | 'isVisible' | 'createdAt' | 'updatedAt'
>

export interface Product {
    id: string
    branchId: string
    productId: string
    salesId: string
    salesName: string
    category: Category
    brand: Brand
    name: string
    description: string
    size: string
    imageUrl: string
    point: number
    price: PriceList[]
    warehouse: Warehouse[]
    orderCount: number
    isVisible: boolean
    createdAt: string
    updatedAt: string
}

export interface ReqProductFind extends ReqPaging {
    branchId?: string
    brandId?: string
    categoryId?: string
    team?: string
    salesId?: string
    sort?: ESort
}

export interface CreateProduct {
    id: string
    category: Category
    brand: Brand
    name: string
    description: string
    size: string
    point: number
    image_?: File
}

export interface Brand {
    id: string
    name: string
    imageUrl: string
}

export interface Category {
    id: string
    name: string
    team: number
}

export interface PriceList {
    id: string
    name: string
    price: number
    discount: Discount[]
}

export interface Discount {
    min: number
    max: number | null
    discount: number
    startAt: string
    expiredAt: string
}

export interface WarehouseList {
    id: string
    name: string
    qty: number
}

export interface ProductPrice {
    branchId: string
    productId: string
    price: PriceList[]
}

export interface Price {
    id: string
    name: string
    price: number
}

export interface CreateQty {
    branchId: string
    productId: string
    warehouseId: string
    warehouseName: string
    qty: number
    creator: Creator
}

export interface CreateTransferQty {
    // branchId: string
    productId: string
    fromWarehouseId: string
    fromWarehouseName: string
    toWarehouseId: string
    toWarehouseName: string
    qty: number
    creator: Creator
}

export interface Creator {
    id: string
    name: string
    imageUrl: string
    roles: number
}

export interface From {
    id: string
    name: string
    lastQty: number
    newQty: number
}

export interface ProductSales {
    id: string
    name: string
    totalProduct: number
}

export interface UpdateSalesProduct {
    id: string
    branchId: string
    brandId: string
    categoryId: string
    team: number
    salesId: string
    salesName: string
}

export interface HistoryQty {
    id: string
    type: number
    branchId: string
    productId: string
    category: Category
    brand: Brand
    name: string
    description: string
    size: string
    imageUrl: string
    warehouse: Warehouse[]
    qty: number
    creator: Brand
    createdAt: string
}

export interface Warehouse {
    id: string
    name: string
    qty: number
}

export enum ESort {
    'ORDER COUNT' = 1,
    'DISCOUT' = 2,
}

export enum EQtype {
    'BY SEARCH' = 1,
    'BY BRAND' = 2,
    'BY CATEGORY' = 3,
}

export enum ETeam {
    'FOOD' = 1,
    'RETAIL' = 2,
}

export interface RFindProductBranch {
    branchId: string
    sort?: ESort
    qtype?: EQtype
    qvalue?: string
    team?: ETeam
}

export type ReqFindProductInBranch = ReqPaging & RFindProductBranch

export interface UpdateVisibleProductInBranch {
    branchId: string
    productId: string
}

export interface ItemDiscountPrice {
    discount: number
    min: number
    max: number
}
export interface SalesProduct {
    id: string
    name: string
    totalProduct: number
}
