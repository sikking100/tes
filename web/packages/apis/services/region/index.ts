import { ReqPaging, ResPaging } from '../'
import { Api, CreateRegion, Region } from './region'
export type { CreateRegion, Region }
export interface ApiRegionInfo {
    find(r: ReqPaging): Promise<ResPaging<Region>>
    findById(r: string): Promise<Region>
    create(r: CreateRegion): Promise<Region>
    delete(r: string): Promise<Region>
}
export function getRegionApiInfo(): ApiRegionInfo {
    return Api.getInstance()
}
