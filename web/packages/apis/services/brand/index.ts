import { Api, Brand, CreateBrand } from './brand'
export type { Brand, CreateBrand }
export interface ApiBrandInfo {
    find(): Promise<Brand[]>
    findById(id: string): Promise<Brand>
    create(r: CreateBrand): Promise<Brand>
    delete(id: string): Promise<Brand>
}
export function getBrandApiInfo(): ApiBrandInfo {
    return Api.getInstance()
}
