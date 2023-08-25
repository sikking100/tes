import { Api, Banner, BannerType, CreateBanner } from './banner'
export type { Banner, CreateBanner }
export { BannerType }
export interface ApiInfo {
    find(type: BannerType): Promise<Banner[]>
    create(data: CreateBanner): Promise<void>
    deleteById(id: string): Promise<Banner>
}
export function getBannerApiInfo(): ApiInfo {
    return Api.getInstance()
}
