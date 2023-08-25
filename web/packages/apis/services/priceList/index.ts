import { Api, CreatePriceList, PriceList } from './priceList'
export type { CreatePriceList, PriceList }
export interface ApiPriceListInfo {
    find(): Promise<PriceList[]>
    findById(id: string): Promise<PriceList>
    create(r: CreatePriceList): Promise<PriceList>
    delete(id: string): Promise<PriceList>
}
export function getPriceListApiInfo(): ApiPriceListInfo {
    return Api.getInstance()
}
