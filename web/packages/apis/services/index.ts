export * from './banner'
export * from './activity'
export * from './code'
export * from './branch'
export * from './region'
export * from './product'
export * from './employee'
export * from './category'
export * from './brand'
export * from './priceList'
export * from './login'
export * from './help'
export * from './recipe'
export * from './customer'
export * from './order'
export * from './invoice'
export * from './delivery'

export enum Eteam {
    FOOD = 1,
    RETAIL = 2,
}

export interface Type {
    t: 'create' | 'update'
}

export interface ResPaging<Data> {
    back: number | null
    next: number | null
    limit: number
    items: Data[]
}

export interface ReqPaging {
    page?: number
    limit?: number
    search?: string
}

export interface SelectsTypes {
    value: string
    label: string
    image?: string
    extra?: any
}
